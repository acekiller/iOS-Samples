//
//  LEDLabelUIView.m
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEDLabelUIView.h"

@implementation LEDLabelUIView



- (id)initWithFrame:(CGRect)frame {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (id)initWithDegits:(int)numberOfDegits size:(CGFloat)labelFontSize
{
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

	degits = numberOfDegits;
	fontSize = labelFontSize;
	
	if(self = [self initWithFrame:CGRectZero])
	{
		labelArray = [[NSMutableArray alloc] init];
		for (int i = 0; i < numberOfDegits; i++) {
			UILabel *label = [[[UILabel alloc] init] autorelease];
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.font = [UIFont fontWithName:@"DBLCDTempBlack"
										 size:fontSize];
			label.backgroundColor = [UIColor blueColor];
			label.textColor = [UIColor whiteColor];
			label.textAlignment = UITextAlignmentCenter;
			label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
			[labelArray addObject:label];
			[self addSubview:label];
		}		
		
	}
	
	NSLog(@"self ===> %@", self);
	return self;
}

- (void)setNumber:(NSInteger)number
{
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	// 桁数が超えていた場合は超えている桁数は無視する
	UILabel *value;
	fontSize = number;
	CGSize labelSize = CGSizeMake(fontSize / 4 * 3, fontSize);

	for (int i = 0; i < [labelArray count]; i++) {
		value = [labelArray objectAtIndex:i];
		NSLog(@"number = %d", number);
		
		if (number == 0) {
			value.text = @"";
		} else {
			value.text = [NSString stringWithFormat:@"%d", (int)(number % 10)];
			value.font = [UIFont fontWithName:@"DBLCDTempBlack" size:fontSize];
		}
		value.center = self.center;
		value.frame = CGRectMake(((degits - 1) - i )*labelSize.width, value.frame.origin.y, labelSize.width, labelSize.height);
		number = number / 10;
	}
	
	if (degits > 0) {
		UILabel *firstValue = [labelArray objectAtIndex:0];
		if (firstValue.text == @"") {
			firstValue.text = @"0";
		}		
	}
	NSLog(@"labels = %@", labelArray);
	self.frame = CGRectMake(0, 0, labelSize.width * degits, labelSize.height);

	NSLog(@"frame(x, y) = (%f, %f)", self.frame.size.width, self.frame.size.width);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

    [super dealloc];
}


@end
