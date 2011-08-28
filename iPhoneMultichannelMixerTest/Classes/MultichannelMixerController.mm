/*
     File: MultichannelMixerController.mm 
 Abstract: The Controller Class for the AUGraph. 
  Version: 1.0.2 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2009 Apple Inc. All Rights Reserved. 
  
*/

#import "MultiChannelMixerController.h"

const Float64 kGraphSampleRate = 44100.0;

#pragma mark- AUComponentDescription

// a simple wrapper for AudioComponentDescription
class AUComponentDescription : public AudioComponentDescription
{
public:
	AUComponentDescription()
	{
		 	componentType = 0;
			componentSubType = 0;
			componentManufacturer = 0;
			componentFlags = 0;
			componentFlagsMask = 0;
	};
	
			
	AUComponentDescription(OSType inType,
                           OSType inSubType,
                           OSType inManufacturer = 0,
                           unsigned long inFlags = 0,
                           unsigned long inFlagsMask = 0 )
	{
		 	componentType = inType;
			componentSubType = inSubType;
			componentManufacturer = inManufacturer;
			componentFlags = inFlags;
			componentFlagsMask = inFlagsMask;
	};

	AUComponentDescription(const AudioComponentDescription &inDescription) 
    {
		*(AudioComponentDescription*)this = inDescription;
	};
};

#pragma mark- RenderProc

// audio render procedure, don't allocate memory, don't take any locks, don't waste time
static OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    SoundBufferPtr sndbuf = (SoundBufferPtr)inRefCon;
    
    UInt32 bufSamples = sndbuf[inBusNumber].numFrames;
	AudioUnitSampleType *in = sndbuf[inBusNumber].data;

	AudioUnitSampleType *outA = (AudioUnitSampleType *)ioData->mBuffers[0].mData;
	AudioUnitSampleType *outB = (AudioUnitSampleType *)ioData->mBuffers[1].mData;
    
    UInt32 sample = sndbuf[inBusNumber].sampleNum;
	for (UInt32 i = 0; i < inNumberFrames; ++i) {
        if (1 == inBusNumber) {
            outA[i] = 0;
            outB[i] = in[sample++];
        } else {
             outA[i] = in[sample++];
             outB[i] = 0;
        }
        if (sample >= bufSamples) sample = 0;
    }
    sndbuf[inBusNumber].sampleNum = sample;
   // printf("bus %d sample %d\n", inBusNumber, sample);
    
	return noErr;
}

#pragma mark- MultichannelMixerController

@interface MultichannelMixerController (hidden)
 
- (void)loadFiles;
 
@end

@implementation MultichannelMixerController

@synthesize isPlaying;

- (void)dealloc
{    
    printf("MultichannelMixerController dealloc\n");
    
    DisposeAUGraph(mGraph);
    
    free(mSoundBuffer[0].data);
    free(mSoundBuffer[1].data);
    
    CFRelease(sourceURL[0]);
    CFRelease(sourceURL[1]);

	[super dealloc];
}

- (void)awakeFromNib
{
    printf("awakeFromNib\n");
    
	isPlaying = false;

    // clear the mSoundBuffer struct
	memset(&mSoundBuffer, 0, sizeof(mSoundBuffer));
    
    // create the URLs we'll use for source A and B
    NSString *sourceA = [[NSBundle mainBundle] pathForResource:@"GuitarMonoSTP" ofType:@"aif"];
    NSString *sourceB = [[NSBundle mainBundle] pathForResource:@"DrumsMonoSTP" ofType:@"aif"];
    sourceURL[0] = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)sourceA, kCFURLPOSIXPathStyle, false);
    sourceURL[1] = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)sourceB, kCFURLPOSIXPathStyle, false);
}

- (void)initializeAUGraph
{
    printf("initialize\n");
    
    AUNode outputNode;
	AUNode mixerNode;
    CAStreamBasicDescription desc;
	
	OSStatus result = noErr;
    
    // load up the audio data
    [self performSelectorInBackground:@selector(loadFiles) withObject:nil];
    
    // create a new AUGraph
	result = NewAUGraph(&mGraph);
    if (result) { printf("NewAUGraph result %d %08X %4.4s\n", result, result, (char*)&result); return; }
	
    // create two AudioComponentDescriptions for the AUs we want in the graph
    
    // output unit
	AUComponentDescription output_desc(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO, kAudioUnitManufacturer_Apple);
    
    // multichannel mixer unit
	AUComponentDescription mixer_desc(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer, kAudioUnitManufacturer_Apple);

    printf("new nodes\n");

    // create a node in the graph that is an AudioUnit, using the supplied AudioComponentDescription to find and open that unit
	result = AUGraphAddNode(mGraph, &output_desc, &outputNode);
	if (result) { printf("AUGraphNewNode 1 result %lu %4.4s\n", result, (char*)&result); return; }

	result = AUGraphAddNode(mGraph, &mixer_desc, &mixerNode );
	if (result) { printf("AUGraphNewNode 2 result %lu %4.4s\n", result, (char*)&result); return; }

    // connect a node's output to a node's input
	result = AUGraphConnectNodeInput(mGraph, mixerNode, 0, outputNode, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    // open the graph AudioUnits are open but not initialized (no resource allocation occurs here)
	result = AUGraphOpen(mGraph);
	if (result) { printf("AUGraphOpen result %d %08X %4.4s\n", result, result, (char*)&result); return; }
	
	result = AUGraphNodeInfo(mGraph, mixerNode, NULL, &mMixer);
    if (result) { printf("AUGraphNodeInfo result %d %08X %4.4s\n", result, result, (char*)&result); return; }

    // set bus count
	UInt32 numbuses = 2;
	UInt32 size = sizeof(numbuses);
	
    printf("set input bus count %lu\n", numbuses);
	
    result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(UInt32));
    if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", result, result, (char*)&result); return; }

	for (int i = 0; i < numbuses; ++i) {
		// setup render callback struct
		AURenderCallbackStruct rcbs;
		rcbs.inputProc = &renderInput;
		rcbs.inputProcRefCon = mSoundBuffer;
        
        printf("set kAudioUnitProperty_SetRenderCallback\n");
        
        // Set a callback for the specified node's specified input
        result = AUGraphSetNodeInputCallback(mGraph, mixerNode, i, &rcbs);
		// equivalent to AudioUnitSetProperty(mMixer, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, i, &rcbs, sizeof(rcbs));
        if (result) { printf("AUGraphSetNodeInputCallback result %d %08X %4.4s\n", result, result, (char*)&result); return; }

        // set input stream format to what we want
        printf("get kAudioUnitProperty_StreamFormat\n");
		
        size = sizeof(desc);
		result = AudioUnitGetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &desc, &size);
        if (result) { printf("AudioUnitGetProperty result %d %08X %4.4s\n", result, result, (char*)&result); return; }
		
		desc.ChangeNumberChannels(2, false);						
		desc.mSampleRate = kGraphSampleRate;
		
		printf("set kAudioUnitProperty_StreamFormat\n");
        
		result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &desc, sizeof(desc));
        if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", result, result, (char*)&result); return; }
	}
	
	// set output stream format to what we want
    printf("get kAudioUnitProperty_StreamFormat\n");
	
    result = AudioUnitGetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, &size);
    if (result) { printf("AudioUnitGetProperty result %d %08X %4.4s\n", result, result, (char*)&result); return; }
	
	desc.ChangeNumberChannels(2, false);						
	desc.mSampleRate = kGraphSampleRate;

    printf("set kAudioUnitProperty_StreamFormat\n");
    
	result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &desc, sizeof(desc));
    if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", result, result, (char*)&result); return; }
		
    printf("AUGraphInitialize\n");
								
    // now that we've set everything up we can initialize the graph, this will also validate the connections
	result = AUGraphInitialize(mGraph);
    if (result) { printf("AUGraphInitialize result %d %08X %4.4s\n", result, result, (char*)&result); return; }
}

// load up audio data from the demo files into mSoundBuffer.data used in the render proc
- (void)loadFiles
{
    for (int i = 0; i < NUMFILES && i < MAXBUFS; i++)  {
        printf("loadFiles, %d\n", i);
        
        ExtAudioFileRef xafref = 0;
        
        // open one of the two source files
        OSStatus result = ExtAudioFileOpenURL(sourceURL[i], &xafref);
        if (result || !xafref) { printf("ExtAudioFileOpenURL result %d %08X %4.4s\n", result, result, (char*)&result); return; }
        
        // get the file data format, this represents the file's actual data format
        CAStreamBasicDescription clientFormat;
        UInt32 propSize = sizeof(clientFormat);
        
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &clientFormat);
        if (result) { printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileDataFormat result %d %08X %4.4s\n", result, result, (char*)&result); return; }
        
        // set the client format to be what we want back
        double rateRatio = kGraphSampleRate / clientFormat.mSampleRate;
        clientFormat.mSampleRate = kGraphSampleRate;
        clientFormat.SetAUCanonical(1, true);
        
        propSize = sizeof(clientFormat);
        result = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, propSize, &clientFormat);
        if (result) { printf("ExtAudioFileSetProperty kExtAudioFileProperty_ClientDataFormat %d %08X %4.4s\n", result, result, (char*)&result); return; }
        
        // get the file's length in sample frames
        UInt64 numFrames = 0;
        propSize = sizeof(numFrames);
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileLengthFrames, &propSize, &numFrames);
        if (result) { printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileLengthFrames result %d %08X %4.4s\n", result, result, (char*)&result); return; }
        
        numFrames = (UInt32)(numFrames * rateRatio); // account for any sample rate conversion
        
        // set up our buffer
        mSoundBuffer[i].numFrames = numFrames;
        mSoundBuffer[i].asbd = clientFormat;
        
        UInt32 samples = numFrames * mSoundBuffer[i].asbd.mChannelsPerFrame;
        mSoundBuffer[i].data = (AudioUnitSampleType *)calloc(samples, sizeof(AudioUnitSampleType));
        mSoundBuffer[i].sampleNum = 0;
        
        // set up a AudioBufferList to read data into
        AudioBufferList bufList;
        bufList.mNumberBuffers = 1;
        bufList.mBuffers[0].mNumberChannels = 1;
        bufList.mBuffers[0].mData = mSoundBuffer[i].data;
        bufList.mBuffers[0].mDataByteSize = samples * sizeof(AudioUnitSampleType);

        // perform a synchronous sequential read of the audio data out of the file into our allocated data buffer
        UInt32 numPackets = numFrames;
        result = ExtAudioFileRead(xafref, &numPackets, &bufList);
        if (result) {
            printf("ExtAudioFileRead result %d %08X %4.4s\n", result, result, (char*)&result); 
            free(mSoundBuffer[i].data);
            mSoundBuffer[i].data = 0;
            return;
        }
        
        // close the file and dispose the ExtAudioFileRef
        ExtAudioFileDispose(xafref);
    }
}

#pragma mark-

// enable or disables a specific bus
- (void)enableInput:(UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue
{
    printf("BUS %d isON %f\n", inputNum, isONValue);
         
    OSStatus result = AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, inputNum, isONValue, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Enable result %d %08X %4.4s\n", result, result, (char*)&result); return; }

}

// sets the input volume for a specific bus
- (void)setInputVolume:(UInt32)inputNum value:(AudioUnitParameterValue)value
{
	OSStatus result = AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, inputNum, value, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Volume Input result %d %08X %4.4s\n", result, result, (char*)&result); return; }
}

// sets the overall mixer output volume
- (void)setOutputVolume:(AudioUnitParameterValue)value
{
	OSStatus result = AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, value, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Volume Output result %d %08X %4.4s\n", result, result, (char*)&result); return; }
}

// stars render
- (void)startAUGraph
{
    printf("PLAY\n");
    
	OSStatus result = AUGraphStart(mGraph);
    if (result) { printf("AUGraphStart result %d %08X %4.4s\n", result, result, (char*)&result); return; }
	isPlaying = true;
}

// stops render
- (void)stopAUGraph
{
	printf("STOP\n");

    Boolean isRunning = false;
    
    OSStatus result = AUGraphIsRunning(mGraph, &isRunning);
    if (result) { printf("AUGraphIsRunning result %d %08X %4.4s\n", result, result, (char*)&result); return; }
    
    if (isRunning) {
        result = AUGraphStop(mGraph);
        if (result) { printf("AUGraphStop result %d %08X %4.4s\n", result, result, (char*)&result); return; }
        isPlaying = false;
    }
}

@end