
/*
     File: TimeZoneView.m
 Abstract: A view to display various pieces of information about a time zone. Since the the view's content is fairly complex, to optimize scolling performance it draws its content directly in drawRect:.
 
  Version: 2.1
 
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

#import "TimeZoneView.h"
#import "TimeZoneWrapper.h"

@implementation TimeZoneView

@synthesize timeZoneWrapper;
@synthesize dateFormatter;
@synthesize abbreviation;
@synthesize highlighted;
@synthesize editing;


- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		/*
		 Cache the formatter. Normally you would use one of the date formatter styles (such as NSDateFormatterShortStyle), but here we want a specific format that excludes seconds.
		 */
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"h:mm a"];
		self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}


- (void)setTimeZoneWrapper:(TimeZoneWrapper *)newTimeZoneWrapper {
	
	// If the time zone wrapper changes, update the date formatter and abbreviation string.
	if (timeZoneWrapper != newTimeZoneWrapper) {
		[timeZoneWrapper release];
		timeZoneWrapper = [newTimeZoneWrapper retain];
		
		[dateFormatter setTimeZone:timeZoneWrapper.timeZone];
		
		NSString *string = [[NSString alloc] initWithFormat:@"%@ (%@)", timeZoneWrapper.abbreviation, timeZoneWrapper.gmtOffset];
		self.abbreviation = string;
		[string release];
	}
	// May be the same wrapper, but the date may have changed, so mark for redisplay.
	[self setNeedsDisplay];
}


- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
	if (highlighted != lit) {
		highlighted = lit;	
		[self setNeedsDisplay];
	}
}


- (void)drawRect:(CGRect)rect {
	
#define LEFT_COLUMN_OFFSET 10
#define LEFT_COLUMN_WIDTH 130
	
#define MIDDLE_COLUMN_OFFSET 140
#define MIDDLE_COLUMN_WIDTH 110

#define RIGHT_COLUMN_OFFSET 270
	
#define UPPER_ROW_TOP 8
#define LOWER_ROW_TOP 34
	
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 16
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

	// Color and font for the main text items (time zone name, time)
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];

	// Color and font for the secondary text items (GMT offset, day)
	UIColor *secondaryTextColor = nil;
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		mainTextColor = [UIColor whiteColor];
		secondaryTextColor = [UIColor whiteColor];
	}
	else {
		mainTextColor = [UIColor blackColor];
		secondaryTextColor = [UIColor darkGrayColor];
		self.backgroundColor = [UIColor whiteColor];
	}
	
	CGRect contentRect = self.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern.
    if (!self.editing) {
		
		CGFloat boundsX = contentRect.origin.x;
		CGPoint point;
		
		CGFloat actualFontSize;
		CGSize size;
		
		// Set the color for the main text items.
		[mainTextColor set];
		
		/*
		 Draw the locale name top left; use the NSString UIKit method to scale the font size down if the text does not fit in the given area
		*/
		point = CGPointMake(boundsX + LEFT_COLUMN_OFFSET, UPPER_ROW_TOP);
		[timeZoneWrapper.timeZoneLocaleName drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

		/*
		 Draw the current time, right-aligned in the middle column.
		 To ensure it is right-aligned, first find its width with the given font and minimum allowed font size. Then draw the string at the appropriate offset.
		 */
		NSString *timeString = [dateFormatter stringFromDate:[NSDate date]];
		size = [timeString sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
		
		point = CGPointMake(boundsX + MIDDLE_COLUMN_OFFSET + MIDDLE_COLUMN_WIDTH - size.width, UPPER_ROW_TOP);
		[timeString drawAtPoint:point forWidth:MIDDLE_COLUMN_WIDTH withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		
		// Set the color for the secondary text items.
		[secondaryTextColor set];

		/*
		 Draw the abbreviation botton left; use the NSString UIKit method to scale the font size down if the text does not fit in the given area.
		 */
		point = CGPointMake(boundsX + LEFT_COLUMN_OFFSET, LOWER_ROW_TOP);
		[abbreviation drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

		/*
		 Draw the whichDay string, right-aligned in the middle column.
		 To ensure it is right-aligned, first find its width with the given font and minimum allowed font size. Then draw the string at the appropriate offset.
		 */
		size = [timeZoneWrapper.whichDay sizeWithFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
		
		point = CGPointMake(boundsX + MIDDLE_COLUMN_OFFSET + MIDDLE_COLUMN_WIDTH - size.width, LOWER_ROW_TOP);
		[timeZoneWrapper.whichDay drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:secondaryFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		
		// Draw the quarter image.
		CGFloat imageY = (contentRect.size.height - timeZoneWrapper.image.size.height) / 2;
		
		point = CGPointMake(boundsX + RIGHT_COLUMN_OFFSET, imageY);
		[timeZoneWrapper.image drawAtPoint:point];
	}
}


- (void)dealloc {
	[timeZoneWrapper release];
	[dateFormatter release];
	[abbreviation release];
    [super dealloc];
}


@end
