//
//  LEDLabelUIView.h
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LEDLabelUIView : UIView {
	int degits;
	CGFloat fontSize;
	NSMutableArray *labelArray; // 0番目のオブジェクトが0桁目
	
}


- (id)initWithDegits:(int)numberOfDegits size:(CGFloat)labelFontSize;
- (void)setNumber:(NSInteger)number;

@end
