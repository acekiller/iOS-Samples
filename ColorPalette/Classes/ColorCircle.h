//
//  ColorCircle.h
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"

// 定数ヘッダインポート
#import "Constants.h"

@class FirstViewController;

@interface ColorCircle : UIView {
	FirstViewController *firstViewController;
	
	int saturation; // 彩度: 0 - 100 %
	int brightness; // 明度: 0 - 100 %
}

@property (nonatomic, retain) FirstViewController *firstViewController;
@property (assign) int saturation;
@property (assign) int brightness;

@end
