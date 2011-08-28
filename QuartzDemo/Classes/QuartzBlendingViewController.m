/*
     File: QuartzBlendingViewController.m
 Abstract: A QuartzViewController subclass that manages a QuartzBlendingView and a UI to allow for the selection of foreground color, background color and blending mode to demonstrate.
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

#import "QuartzBlendingViewController.h"
#import "QuartzBlending.h"

// Private required methods.
@interface QuartzBlendingViewController()
@property(nonatomic, readwrite, retain) UIPickerView *picker;
@property(nonatomic, readonly) NSArray *colors;
@end

@implementation QuartzBlendingViewController

@synthesize picker;

// These strings represent the actual blend mode constants
// that are passed to CGContextSetBlendMode and as such
// should not be localized in the context of this sample.
static NSString *blendModes[] = {
	// PDF Blend Modes
	@"Normal",
	@"Multiply",
	@"Screen",
	@"Overlay",
	@"Darken",
	@"Lighten",
	@"ColorDodge",
	@"ColorBurn",
	@"SoftLight",
	@"HardLight",
	@"Difference",
	@"Exclusion",
	@"Hue",
	@"Saturation",
	@"Color",
	@"Luminosity",
	// Porter-Duff Blend Modes
	@"Clear",
	@"Copy",
	@"SourceIn",
	@"SourceOut",
	@"SourceAtop",
	@"DestinationOver",
	@"DestinationIn",
	@"DestinationOut",
	@"DestinationAtop",
	@"XOR",
	@"PlusDarker",
	@"PlusLighter",
	// Should Quartz provide more blend modes in the future, here would be the place to add them!
};
static NSInteger blendModeCount = sizeof(blendModes) / sizeof(blendModes[0]);

-(id)init
{
	return [super initWithNibName:@"BlendView" viewClass:[QuartzBlendingView class]];
}

// Setup the picker's default components.
-(void)viewDidLoad
{
	[super viewDidLoad];
	QuartzBlendingView *qbv = (QuartzBlendingView*)self.quartzView;
	[picker selectRow:[self.colors indexOfObject:qbv.destinationColor] inComponent:0 animated:NO];
	[picker selectRow:[self.colors indexOfObject:qbv.sourceColor] inComponent:1 animated:NO];
	[picker selectRow:qbv.blendMode inComponent:2 animated:NO];
}

-(void)dealloc
{
	[picker release]; picker = nil;
	[super dealloc];
}

// Calculate the luminance for an arbitrary UIColor instance
CGFloat luminanceForColor(UIColor *color)
{
	CGColorRef cgColor = color.CGColor;
	const CGFloat *components = CGColorGetComponents(cgColor);
	CGFloat luminance = 0.0;
	switch(CGColorSpaceGetModel(CGColorGetColorSpace(cgColor)))
	{
		case kCGColorSpaceModelMonochrome:
			// For grayscale colors, the luminance is the color value
			luminance = components[0];
			break;
			
		case kCGColorSpaceModelRGB:
			// For RGB colors, we calculate luminance assuming sRGB Primaries as per
			// http://en.wikipedia.org/wiki/Luminance_(relative)
			luminance = 0.2126 * components[0] + 0.7152 * components[1] + 0.0722 * components[2];
			break;
			
		default:
			// We don't implement support for non-gray, non-rgb colors at this time.
			// Since our only consumer is colorSortByLuminance, we return a larger than normal
			// value to ensure that these types of colors are sorted to the end of the list.
			luminance = 2.0;
	}
	return luminance;
}

// Simple comparison function that sorts the two (presumed) UIColors according to their luminance value.
NSInteger colorSortByLuminance(id color1, id color2, void *context)
{
	CGFloat luminance1 = luminanceForColor(color1);
	CGFloat luminance2 = luminanceForColor(color2);
	if(luminance1 == luminance2)
	{
		return NSOrderedSame;
	}
	else if(luminance1 < luminance2)
	{
		return NSOrderedAscending;
	}
	else
	{
		return NSOrderedDescending;
	}
}

-(NSArray*)colors
{
	static NSArray *colorArray = nil;
	if(colorArray == nil)
	{
		// If you want to add more colors to the demo, here would be the place
		// You can also add patterns if you like, they will simply be sorted
		// to the end of the list.
		NSArray *unsortedArray = [NSArray arrayWithObjects:
			[UIColor redColor],
			[UIColor greenColor],
			[UIColor blueColor],
			[UIColor yellowColor],
			[UIColor magentaColor],
			[UIColor cyanColor],
			[UIColor orangeColor],
			[UIColor purpleColor],
			[UIColor brownColor],
			[UIColor whiteColor],
			[UIColor lightGrayColor],
			[UIColor darkGrayColor],
			[UIColor blackColor],
			nil];
		colorArray = [[unsortedArray sortedArrayUsingFunction:colorSortByLuminance context:nil] retain];
	}
	return colorArray;
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSInteger numComps = 0;
	switch(component)
	{
		case 0:
		case 1:
			numComps = [self.colors count];
			break;
			
		case 2:
			numComps = blendModeCount;
			break;
	}
	return numComps;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat width = 0.0;
	switch (component)
	{
		case 0:
		case 1:
			width = 48.0;
			break;
		case 2:
			width = 192.0;
			break;
	}
	return width;
}

#define kColorTag 1
#define kLabelTag 2
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	switch (component)
	{
		case 0:
		case 1:
			if(view.tag != kColorTag)
			{
				CGRect frame = CGRectZero;
				frame.size = [pickerView rowSizeForComponent:component];
				frame = CGRectInset(frame, 4.0, 4.0);
				view = [[[UIView alloc] initWithFrame:frame] autorelease];
				view.tag = kColorTag;
				view.userInteractionEnabled = NO;
			}
			view.backgroundColor = [self.colors objectAtIndex:row];
			break;

		case 2:
			if(view.tag != kLabelTag)
			{
				CGRect frame = CGRectZero;
				frame.size = [pickerView rowSizeForComponent:component];
				frame = CGRectInset(frame, 4.0, 4.0);
				view = [[[UILabel alloc] initWithFrame:frame] autorelease];
				view.tag = kLabelTag;
				view.opaque = NO;
				view.backgroundColor = [UIColor clearColor];
				view.userInteractionEnabled = NO;
			}
			UILabel *label = (UILabel*)view;
			label.textColor = [UIColor blackColor];
			label.text = blendModes[row];
			label.font = [UIFont boldSystemFontOfSize:18.0];
			break;
	}
	return view;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	QuartzBlendingView *qbv = (QuartzBlendingView*)self.quartzView;
	qbv.destinationColor = [self.colors objectAtIndex:[picker selectedRowInComponent:0]];
	qbv.sourceColor = [self.colors objectAtIndex:[picker selectedRowInComponent:1]];
	qbv.blendMode = [picker selectedRowInComponent:2];
}

@end
