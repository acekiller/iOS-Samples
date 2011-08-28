/*

    File: avTouchController.h
Abstract: Base app controller class
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CALevelMeter;

@interface avTouchController : NSObject <UIPickerViewDelegate, AVAudioPlayerDelegate> {

	IBOutlet UILabel					*_fileName;
	IBOutlet UIButton					*_playButton;
	IBOutlet UIButton					*_ffwButton;
	IBOutlet UIButton					*_rewButton;
	IBOutlet UISlider					*_volumeSlider;
	IBOutlet UISlider					*_progressBar;
	IBOutlet UILabel					*_currentTime;
	IBOutlet UILabel					*_duration;
	IBOutlet CALevelMeter				*_lvlMeter_in;
	
	AVAudioPlayer						*_player;
	UIImage								*_playBtnBG, *_pauseBtnBG;
	NSTimer								*_updateTimer;
	NSTimer								*_rewTimer;
	NSTimer								*_ffwTimer;
	NSMutableArray						*_soundFiles;
}

- (IBAction)playButtonPressed:(UIButton *)sender;
- (IBAction)rewButtonPressed:(UIButton *)sender;
- (IBAction)rewButtonReleased:(UIButton *)sender;
- (IBAction)ffwButtonPressed:(UIButton *)sender;
- (IBAction)ffwButtonReleased:(UIButton *)sender;
- (IBAction)volumeSliderMoved:(UISlider *)sender;
- (IBAction)progressSliderMoved:(UISlider *)sender;

@property (nonatomic, retain) UILabel*			_fileName;
@property (nonatomic, retain) UIButton*			_playButton;
@property (nonatomic, retain) UIButton*			_ffwButton;
@property (nonatomic, retain) UIButton*			_rewButton;
@property (nonatomic, retain) UISlider*			_volumeSlider;
@property (nonatomic, retain) UISlider*			_progressBar;
@property (nonatomic, retain) UILabel*			_currentTime;
@property (nonatomic, retain) UILabel*			_duration;
@property (nonatomic, retain) CALevelMeter*		_lvlMeter_in;

@property (nonatomic, retain)	NSTimer*		_updateTimer;
@property (nonatomic, assign)	AVAudioPlayer*	_player;
@end