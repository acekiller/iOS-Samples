/*

    File: avTouchController.mm
Abstract: n/a
 Version: 1.2

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

Copyright (C) 2010 Apple Inc. All Rights Reserved.


*/

#import "avTouchController.h"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#include "CALevelMeter.h"

// amount to skip on rewind or fast forward
#define SKIP_TIME 1.0			
// amount to play between skips
#define SKIP_INTERVAL .2

@interface avTouchController(PrivateMethods)

- (void)updateCurrentTime;
- (void)updateViewForPlayerState;
- (void)updateViewForPlayerInfo;

- (void)setupAudioSession;

- (void)ffwd;
- (void)rewind;

@end

@implementation avTouchController

@synthesize _fileName;
@synthesize _playButton;
@synthesize _ffwButton;
@synthesize _rewButton;
@synthesize _volumeSlider;
@synthesize _progressBar;
@synthesize _currentTime;
@synthesize _duration;
@synthesize _lvlMeter_in;
@synthesize _updateTimer;
@synthesize _player;

- (void)awakeFromNib
{
	// Make the array to store our AVAudioPlayer objects
	_soundFiles = [[NSMutableArray alloc] initWithCapacity:3];

	_playBtnBG = [[[UIImage imageNamed:@"play.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] retain];
	_pauseBtnBG = [[[UIImage imageNamed:@"pause.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] retain];

	[_playButton setImage:_playBtnBG forState:UIControlStateNormal];
			
	_updateTimer = nil;
	_rewTimer = nil;
	_ffwTimer = nil;
	
	self._duration.adjustsFontSizeToFitWidth = YES;
	self._currentTime.adjustsFontSizeToFitWidth = YES;
	self._progressBar.minimumValue = 0.0;	
	
	// Load the array with the sample file
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"m4a"]];
	self._player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];	
	if (self._player)
	{
		_fileName.text = [NSString stringWithFormat: @"%@ (%d ch.)", [[self._player.url relativePath] lastPathComponent], self._player.numberOfChannels, nil];
		[self updateViewForPlayerInfo];
		[self updateViewForPlayerState];
	}
	
	[fileURL release];
}

- (void)pausePlayback
{
	[self._player pause];
	[self updateViewForPlayerState];
}

- (void)startPlayback
{
	if ([self._player play])
	{
		[self updateViewForPlayerState];
		self._player.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self._player.url);
}

- (IBAction)playButtonPressed:(UIButton *)sender
{
	if (self._player.playing == YES)
		[self pausePlayback];
	else
		[self startPlayback];
}

- (IBAction)rewButtonPressed:(UIButton *)sender
{
	if (_rewTimer) [_rewTimer invalidate];
	_rewTimer = [NSTimer scheduledTimerWithTimeInterval:SKIP_INTERVAL target:self selector:@selector(rewind) userInfo:self._player repeats:YES];
}

- (IBAction)rewButtonReleased:(UIButton *)sender
{
	if (_rewTimer) [_rewTimer invalidate];
	_rewTimer = nil;
}

- (IBAction)ffwButtonPressed:(UIButton *)sender
{
	if (_ffwTimer) [_ffwTimer invalidate];
	_ffwTimer = [NSTimer scheduledTimerWithTimeInterval:SKIP_INTERVAL target:self selector:@selector(ffwd) userInfo:self._player repeats:YES];
}

- (IBAction)ffwButtonReleased:(UIButton *)sender
{
	if (_ffwTimer) [_ffwTimer invalidate];
	_ffwTimer = nil;
}

- (IBAction)volumeSliderMoved:(UISlider *)sender
{
	self._player.volume = [sender value];
}

- (IBAction)progressSliderMoved:(UISlider *)sender
{
	self._player.currentTime = sender.value;
	[self updateCurrentTime];
}

- (void)dealloc
{
	[super dealloc];
	[_playBtnBG release];

	[_fileName release];
	[_playButton release];
	[_ffwButton release];
	[_rewButton release];
	[_volumeSlider release];
	[_progressBar release];
	[_currentTime release];
	[_duration release];
	[_lvlMeter_in release];
	[_updateTimer release];
	[_player release];
}

#pragma mark playback methods

- (void)ffwd
{
	AVAudioPlayer *player = _ffwTimer.userInfo;
	player.currentTime+= SKIP_TIME;	
	[self updateCurrentTime];
}

- (void)rewind
{
	AVAudioPlayer *player = _rewTimer.userInfo;
	player.currentTime-= SKIP_TIME;
	[self updateCurrentTime];
}


#pragma mark UI state handlers

-(void)updateCurrentTime
{
	self._currentTime.text = [NSString stringWithFormat:@"%d:%02d", (int)self._player.currentTime / 60, (int)self._player.currentTime % 60, nil];
	self._progressBar.value = self._player.currentTime;
}

- (void)updateViewForPlayerState
{
	[self updateCurrentTime];

	if (self._updateTimer) 
		[self._updateTimer invalidate];
		
	if (self._player.playing)
	{
		[_playButton setImage:((self._player.playing == YES) ? _pauseBtnBG : _playBtnBG) forState:UIControlStateNormal];
		[_lvlMeter_in setPlayer:self._player];
		self._updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:self._player repeats:YES];
	}
	else
	{
		[_playButton setImage:((self._player.playing == YES) ? _pauseBtnBG : _playBtnBG) forState:UIControlStateNormal];
		[_lvlMeter_in setPlayer:nil];
		_updateTimer = nil;
	}
	
}

-(void)updateViewForPlayerInfo
{
	self._duration.text = [NSString stringWithFormat:@"%d:%02d", (int)self._player.duration / 60, (int)self._player.duration % 60, nil];
	self._progressBar.maximumValue = self._player.duration;
	self._volumeSlider.value = self._player.volume;
}

#pragma mark AudioSession methods

void RouteChangeListener(	void *                  inClientData,
							AudioSessionPropertyID	inID,
							UInt32                  inDataSize,
							const void *            inData)
{
	avTouchController* This = (avTouchController*)inClientData;
	
	if (inID == kAudioSessionProperty_AudioRouteChange) {
		
		CFDictionaryRef routeDict = (CFDictionaryRef)inData;
		NSNumber* reasonValue = (NSNumber*)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		
		int reason = [reasonValue intValue];

		if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {

			[This pausePlayback];
		}
	}
}

- (void)setupAudioSession
{
	AVAudioSession *session = [AVAudioSession sharedInstance];
	NSError *error = nil;
	
	[session setCategory: AVAudioSessionCategoryPlayback error: &error];
	if (error != nil)
		NSLog(@"Failed to set category on AVAudioSession");
	
	// AudioSession and AVAudioSession calls can be used interchangeably
	OSStatus result = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, RouteChangeListener, self);
	if (result) NSLog(@"Could not add property listener! %d\n", result);
	
	BOOL active = [session setActive: YES error: nil];
	if (!active)
		NSLog(@"Failed to set category on AVAudioSession");

}

#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
		
	[player setCurrentTime:0.];
	[self updateViewForPlayerState];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error); 
}

// we will only get these notifications if playback was interrupted
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	// the object has already been paused,	we just need to update UI
	[self updateViewForPlayerState];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	[self startPlayback];
}

@end