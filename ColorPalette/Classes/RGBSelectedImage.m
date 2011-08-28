//
//  RGBSelectedImage.m
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RGBSelectedImage.h"


@implementation RGBSelectedImage


@synthesize selected;
@synthesize colorR;
@synthesize colorG;
@synthesize colorB;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)setColorWithR:(int)valueR G:(int)valueG B:(int)valueB
{
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

	colorR = valueR;
	colorG = valueG;
	colorB = valueB;
	
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	NSLog(@"R,G,B = %d, %d, %d", colorR, colorG, colorB);
	
	// キャンパス一杯に指定された色で描画する
	CGContextRef context  = UIGraphicsGetCurrentContext(); // 現在のコンテキストを取得する
	CGContextSaveGState(context); // 最後に変更されたコンテキストを戻すために現在の状態を保存する
	
	CGRect currentRect = CGRectMake(0 , 0, self.frame.size.width, self.frame.size.height);	
	NSLog(@"frame(w,h) = (%f, %f)", self.frame.size.width, self.frame.size.height);
	
	CGContextSetLineWidth(context, kRGBRectStrokeWidth);
	if (selected == YES) {
		NSLog(@"selected activated");
		CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:(255 - colorR)/255.0
																green:(255 - colorG)/255.0
																 blue:(255 - colorB)/255.0
																alpha:1.0].CGColor);
		
	} else {
		CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
	}

	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:colorR/255.0
															green:colorG/255.0
															 blue:colorB/255.0
															alpha:1.0].CGColor);
	
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);	
	CGContextRestoreGState(context);
	
}

- (void)dealloc {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

    [super dealloc];
}


@end
