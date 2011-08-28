//
//  RGBSelectedImage.h
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定数ヘッダインポート
#import "Constants.h"

@interface RGBSelectedImage : UIView {
	int colorR; // R: 0 - 255
	int colorG; // G: 0 - 255
	int colorB; // B: 0 - 255
	
	BOOL selected; // Viewがタッチされて選択されている時はYESとする
}

@property (assign) BOOL selected;
@property (assign) int colorR;
@property (assign) int colorG;
@property (assign) int colorB;

- (void)setColorWithR:(int)valueR G:(int)valueG B:(int)valueB;

@end
