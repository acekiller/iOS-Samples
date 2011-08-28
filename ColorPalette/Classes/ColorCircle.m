//
//  ColorCircle.m
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ColorCircle.h"


// プライベートメソッド追加用カテゴリ
@interface ColorCircle (PrivateMethods)

- (void)drawRectWithSize:(CGSize)cubeSize 
				  origin:(CGPoint)origin 
				  radian:(float)radian 
			 insideColor:(CGColorRef)insideColor 
			outsideColor:(CGColorRef)outsideColor;
- (void)drawColorCircle:(int)numberOfRect;

@end


@implementation ColorCircle

@synthesize firstViewController;
@synthesize saturation;
@synthesize brightness;



- (id)initWithFrame:(CGRect)frame {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

    if ((self = [super initWithFrame:frame])) {
        // Initialization code

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	
	NSLog(@"self = %@", self);
	NSLog(@"background = %@", self.backgroundColor);
	
	[self drawColorCircle:(int)firstViewController.numberOfColorsSlider.value];
	self.backgroundColor = [UIColor blackColor];
	
}

/*
- (void)layoutSubviews
{
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	
	[super layoutSubviews];
	self.backgroundColor = [UIColor blackColor];

	// [self drawColorCircle:(int)firstViewController.numberOfColorsSlider.value];
}
 */


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark PrivateMethods

- (void)drawRectWithSize:(CGSize)cubeSize 
				  origin:(CGPoint)origin 
				  radian:(float)radian 
			 insideColor:(CGColorRef)insideColor 
			outsideColor:(CGColorRef)outsideColor
{
	// NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	
	// NSLog(@"origin (x, y) = (%f, %f)", origin.x, origin.y);
	
	CGContextRef context  = UIGraphicsGetCurrentContext(); // 現在のコンテキストを取得する
	CGContextSaveGState(context); // 最後に変更されたコンテキストを戻すために現在の状態を保存する
	
	CGPoint originBeforeMove = CGPointMake( -(cubeSize.width / 2), -(cubeSize.height / 2)); // 回転前の四角形原点
	CGRect currentRect = CGRectMake(originBeforeMove.x , originBeforeMove.y, cubeSize.width, cubeSize.height);	
	CGContextTranslateCTM(context, origin.x, origin.y);
	CGContextRotateCTM(context, radian);
	
	// Drawing code
	CGContextSetLineWidth(context, kColorCircleRectStrokeWidth);
	CGContextSetStrokeColorWithColor(context, outsideColor);
	CGContextSetFillColorWithColor(context, insideColor);
	CGContextAddRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);
	
	CGContextRestoreGState(context);
	
}

// 色相環を作成する
// 色相は４つ以上とする
- (void)drawColorCircle:(int)numberOfRect
{
	// ４色以下の場合は何もしない
	if (kMinimumNumberOfColors <= numberOfRect && numberOfRect <= kMaximumNumberOfColors) 
	{
		float rotateAngle = 360.0 / numberOfRect; // ある色四角形ととなりの色四角形を円の中心から線を結んだときの線と線の間の角度
		float colorRectWidth = 320.0 / ( 2 + 1.0 / tan(radians(rotateAngle / 2)) );
		float colorCircleRadius = 160.0 - colorRectWidth / 2;
		NSLog(@"recWid = %f, circRadius = %f", colorRectWidth, colorCircleRadius);
		
		for (int i = 0; i < numberOfRect; i++) {
			// 色四角形のサイズを計算する
			
			float colorRectOriginX = self.frame.size.width / 2 + colorCircleRadius * cos(radians(90 - rotateAngle * i));
			float colorRectOriginY = self.frame.size.height / 2 - colorCircleRadius * sin(radians(90 - rotateAngle * i));

			float colorRectHue = 1.0 - 1.0 / numberOfRect * i;
			UIColor *colorRectColor = [UIColor colorWithHue:colorRectHue
												 saturation:saturation/100.0
												 brightness:brightness/100.0 
													  alpha:1.0];
			UIColor *colorRectStrokeColor = [UIColor clearColor];
			
			[self drawRectWithSize:CGSizeMake(colorRectWidth * kWidthScale, colorRectWidth * kWidthScale)			
							origin:CGPointMake(colorRectOriginX, colorRectOriginY)
							radian:radians(rotateAngle * i)
					   insideColor:colorRectColor.CGColor
					  outsideColor:colorRectStrokeColor.CGColor];			
		}
	}
	
}


@end
