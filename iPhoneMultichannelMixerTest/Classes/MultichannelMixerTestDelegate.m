/*
     File: MultichannelMixerTestDelegate.m 
 Abstract: The application delegate class.
  
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

#import "MultichannelMixerTestDelegate.h"

@implementation MultichannelMixerTestDelegate

@synthesize window, navigationController, myViewController;

#pragma mark -Audio Session Interruption Listener

static void interruptionListener(void *inClientData, UInt32 inInterruption)
{
	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
	
	MultichannelMixerTestDelegate *THIS = (MultichannelMixerTestDelegate *)inClientData;
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		AudioSessionSetActive(true);
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
        // session is already set to not active so if we're playing stop
        [THIS->myViewController stopForInterruption];
    }
}

#pragma mark -Audio Session Property Listener

static void propertyListener(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData)
{
	//MultichannelMixerTestDelegate *THIS = (MultichannelMixerTestDelegate *)inClientData;
    
	if (inID == kAudioSessionProperty_AudioRouteChange) {
		try {
            CFDictionaryRef	routeChangeDictionary = (CFDictionaryRef)inData;
	
            UInt32 routeChangeReason;
            CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
            CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
            printf("Audio Route Change, Reason: %d\n", routeChangeReason);
            
            CFStringRef routeChangeOldRouteRef = (CFStringRef)CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
            printf("Old Route: ");
            CFShow(routeChangeOldRouteRef);
            
			CFStringRef newRoute;
			UInt32 size = sizeof(newRoute);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute), "couldn't get new audio route");
			if (newRoute) {
                printf("New Route: ");
				CFShow(newRoute);
            }
		} catch (CAXException e) {
			char buf[256];
			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
    
    try {
        // Initialize and configure the audio session
        XThrowIfError(AudioSessionInitialize(NULL, NULL, interruptionListener, self), "couldn't initialize audio session");
            
        UInt32 audioCategory = kAudioSessionCategory_MediaPlayback;
        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
        XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propertyListener, self), "couldn't set property listener");
            
        Float32 preferredBufferSize = .005;
        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
        
        Float64 hwSampleRate = 44100.0;
        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, sizeof(hwSampleRate), &hwSampleRate), "couldn't set hw sample rate");
        
        XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        
        UInt32 size = sizeof(hwSampleRate);
        XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate), "couldn't get hw sample rate");
        printf("Hardware Sample Rate: %f\n", hwSampleRate);
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }

    // initialize the mixerController object
    [myViewController.mixerController initializeAUGraph];
    
    // set up the mixer according to our interface defaults
    [myViewController setUIDefaults];
}

- (void)dealloc {
    self.window = nil;
    self.navigationController = nil;
    self.myViewController = nil;
    
    [super dealloc];
}

@end
