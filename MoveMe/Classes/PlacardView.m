
/*
     File: PlacardView.m
 Abstract: Displays a UIImage with text superimposed.
 
  Version: 2.7
 
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

#import "PlacardView.h"


@implementation PlacardView

@synthesize placardImage;
@synthesize currentDisplayString;
@synthesize displayStrings;


- (id)init {
	// Retrieve the image for the view and determine its size
	UIImage *image = [UIImage imageNamed:@"Placard.png"];
	CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
	
	// Set self's frame to encompass the image
	if (self = [self initWithFrame:frame]) {

		self.opaque = NO;
		placardImage = image;
		
		// Load the display strings
		NSString *path = [[NSBundle mainBundle] pathForResource:@"DisplayStrings" ofType:@"strings"];
		NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF16BigEndianStringEncoding error:NULL];
		self.displayStrings = [string componentsSeparatedByString:@"\n"];
		displayStringsIndex = 0;
		[self setupNextDisplayString];
	}
	return self;
}


- (void)dealloc {
	[placardImage release];
	[currentDisplayString release];
	[displayStrings release];
	[super dealloc];
}


#define STRING_INDENT 20

- (void)drawRect:(CGRect)rect {
	
	// Draw the placard at 0, 0
	[placardImage drawAtPoint:(CGPointMake(0.0, 0.0))];
	
	/*
	 Draw the current display string.
	 Typically you would use a UILabel, but this example serves to illustrate the UIKit extensions to NSString.
	 The text is drawn center of the view twice - first slightly offset in black, then in white -- to give an embossed appearance.
	 The size of the font and text are calculated in setupNextDisplayString.
	 */
	
	// Find point at which to draw the string so it will be in the center of the view
	CGFloat x = self.bounds.size.width/2 - textSize.width/2;
	CGFloat y = self.bounds.size.height/2 - textSize.height/2;
	CGPoint point;
	
	// Get the font of the appropriate size
	UIFont *font = [UIFont systemFontOfSize:fontSize];

	[[UIColor blackColor] set];
	point = CGPointMake(x, y + 0.5);
	[currentDisplayString drawAtPoint:point forWidth:(self.bounds.size.width-STRING_INDENT) withFont:font fontSize:fontSize lineBreakMode:UILineBreakModeMiddleTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

	[[UIColor whiteColor] set];
	point = CGPointMake(x, y);
	[currentDisplayString drawAtPoint:point forWidth:(self.bounds.size.width-STRING_INDENT) withFont:font fontSize:fontSize lineBreakMode:UILineBreakModeMiddleTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines]; 
}


- (void)setupNextDisplayString {
	
	// Get the string at the current index, then increment the index
	self.currentDisplayString = [displayStrings objectAtIndex:displayStringsIndex];
	displayStringsIndex++;
	if (displayStringsIndex >= [displayStrings count]) {
		displayStringsIndex = 0;
	}
	
	UIFont *font = [UIFont systemFontOfSize:24];
	// Precalculate size of text and size of font so that text fits inside placard
	textSize = [currentDisplayString sizeWithFont:font minFontSize:9.0 actualFontSize:&fontSize forWidth:(self.bounds.size.width-STRING_INDENT) lineBreakMode:UILineBreakModeMiddleTruncation];

	[self setNeedsDisplay];
}


@end
