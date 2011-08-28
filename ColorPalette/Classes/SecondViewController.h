//
//  SecondViewController.h
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGBSelectedImage.h"


@interface SecondViewController : UIViewController {
	// RGB用のボタンとスライダー
	IBOutlet UISlider *colorRSlider;
	IBOutlet UIButton *minusRButton;
	IBOutlet UIButton *plusRButton;
	IBOutlet UISlider *colorGSlider;
	IBOutlet UIButton *minusGButon;
	IBOutlet UIButton *plusGButton;
	IBOutlet UISlider *colorBSlider;
	IBOutlet UIButton *minusBButton;
	IBOutlet UIButton *plusBButton;
	
	// 値表示用のラベル
	IBOutlet UILabel *colorWebValueLabel;
	IBOutlet UILabel *colorRValueLabel;
	IBOutlet UILabel *colorGValueLabel;
	IBOutlet UILabel *colorBValueLabel;

	// 描画用のUIView
	IBOutlet RGBSelectedImage *selectedView;
	RGBSelectedImage *selectedViewInSamples;
	
	// SampleUIView
	NSMutableArray *colorRGBSelectedImages;
	IBOutlet RGBSelectedImage *sampleView_1;
	IBOutlet RGBSelectedImage *sampleView_2;
	IBOutlet RGBSelectedImage *sampleView_3;
	IBOutlet RGBSelectedImage *sampleView_4;
	IBOutlet RGBSelectedImage *sampleView_5;
	IBOutlet RGBSelectedImage *sampleView_6;
	
	// Backgroundのカラー
	int backgroundColorR;
	int backgroundColorG;
	int backgroundColorB;

}

// RGB用のボタンとスライダー
@property (nonatomic, retain) UISlider *colorRSlider;
@property (nonatomic, retain) UIButton *minusRButton;
@property (nonatomic, retain) UIButton *plusRButton;
@property (nonatomic, retain) UISlider *colorGSlider;
@property (nonatomic, retain) UIButton *minusGButon;
@property (nonatomic, retain) UIButton *plusGButton;
@property (nonatomic, retain) UISlider *colorBSlider;
@property (nonatomic, retain) UIButton *minusBButton;
@property (nonatomic, retain) UIButton *plusBButton;

// 値表示用のラベル
@property (nonatomic, retain) UILabel *colorWebValueLabel;
@property (nonatomic, retain) UILabel *colorRValueLabel;
@property (nonatomic, retain) UILabel *colorGValueLabel;
@property (nonatomic, retain) UILabel *colorBValueLabel;

// 描画用のUIView
@property (nonatomic, retain) RGBSelectedImage *selectedView;

// SampleUIView
@property (nonatomic, retain) RGBSelectedImage *sampleView_1;
@property (nonatomic, retain) RGBSelectedImage *sampleView_2;
@property (nonatomic, retain) RGBSelectedImage *sampleView_3;
@property (nonatomic, retain) RGBSelectedImage *sampleView_4;
@property (nonatomic, retain) RGBSelectedImage *sampleView_5;
@property (nonatomic, retain) RGBSelectedImage *sampleView_6;


//////////////////////////////////////////////////////////////
// RGB用のボタンとスライダーがおされた時
- (IBAction)colorRSliderChanged:(id)sender;
- (IBAction)minusRButtonPressed:(id)sender;
- (IBAction)plusRButtonPressed:(id)sender;
- (IBAction)colorGSliderChanged:(id)sender;
- (IBAction)minusGButtonPressed:(id)sender;
- (IBAction)plusGButtonPressed:(id)sender;
- (IBAction)colorBSliderChanged:(id)sender;
- (IBAction)minusBButtonPressed:(id)sender;
- (IBAction)plusBButtonPressed:(id)sender;

// ラベルの値を設定する
- (void)setLabelsWithR:(int)colorR G:(int)colorG B:(int)colorB;
- (void)valueChangedByAction;

// backgoundの色を調整する
- (void)setBackgroundColorsWithR:(int)colorR G:(int)colorG B:(int)colorB;

// 選択されたViewとのサンプルのViewの調整をする
- (void)selectedViewChanged;

@end
