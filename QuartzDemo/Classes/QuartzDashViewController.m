/*
     File: QuartzDashViewController.m
 Abstract: A QuartzViewController subclass that manages a QuartzDashView and a UI to allow for the selection of the line dash pattern and phase.
  Version: 2.3
 
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

#import "QuartzDashViewController.h"
#import "QuartzLines.h"

@interface QuartzDashViewController()
@property(nonatomic, readwrite, retain) UIPickerView *picker;
@end

@implementation QuartzDashViewController

@synthesize picker;

// These strings represent the actual drawing mode constants
// that are passed to CGContextDrawpath and as such
// should not be localized in the context of this sample
typedef struct {
	CGFloat pattern[5];
	size_t count;
} Pattern;
static Pattern patterns[] = {
	{{10.0, 10.0}, 2},
	{{10.0, 20.0, 10.0}, 3},
	{{10.0, 20.0, 30.0}, 3},
	{{10.0, 20.0, 10.0, 30.0}, 4},
	{{10.0, 10.0, 20.0, 20.0}, 4},
	{{10.0, 10.0, 20.0, 30.0, 50.0}, 5},
};
static NSInteger patternCount = sizeof(patterns) / sizeof(patterns[0]);

-(id)init
{
	return [super initWithNibName:@"DashView" viewClass:[QuartzDashView class]];
}

// Setup the picker's default components.
-(void)viewDidLoad
{
	[super viewDidLoad];
	QuartzDashView *ldv = (QuartzDashView*)self.quartzView;
	[ldv setDashPattern:patterns[0].pattern count:patterns[0].count];
	[picker selectRow:0 inComponent:0 animated:NO];
}

-(void)dealloc
{
	[picker release]; picker = nil;
	[super dealloc];
}

-(IBAction)dashPhase
{
	QuartzDashView *ldv = (QuartzDashView*)self.quartzView;
	ldv.dashPhase = phase.value;
}

-(IBAction)reset
{
	QuartzDashView *ldv = (QuartzDashView*)self.quartzView;
	ldv.dashPhase = 0.0;
	phase.value = 0.0;
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return patternCount;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
	Pattern p = patterns[row];
	NSMutableString *title = [NSMutableString stringWithFormat:@"%.0f", p.pattern[0]];
	for(size_t i = 1; i < p.count; ++i)
	{
		[title appendFormat:@"-%.0f", p.pattern[i]];
	}
	return title;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	QuartzDashView *ldv = (QuartzDashView*)self.quartzView;
	[ldv setDashPattern:patterns[row].pattern count:patterns[row].count];
}

@end
