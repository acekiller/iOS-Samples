//
//  FirstViewController.h
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorCircle.h"
#import "LEDLabelUIView.h"

@class ColorCircle;

@interface FirstViewController : UIViewController {
	IBOutlet ColorCircle *colorCircleView;
	NSMutableArray *numberOfColorsLabelArray;
	IBOutlet UILabel *numberOfColorsLabel_1;
	IBOutlet UILabel *numberOfColorsLabel_10;
	IBOutlet UILabel *saturationLabel;
	IBOutlet UILabel *brightnessLabel;
	IBOutlet UISlider *numberOfColorsSlider;
	IBOutlet UISlider *saturationSlider;
	IBOutlet UISlider *brightnessSlider;
	
	LEDLabelUIView *numberOfColorsView;
	
	int formerSliderValue;
	int formerSaturationSliderValue;
	int formerBrightSliderValue;
}

@property (nonatomic, retain) UIView *colorCircleView;
@property (nonatomic, retain) UILabel *numberOfColorsLabel_1;
@property (nonatomic, retain) UILabel *numberOfColorsLabel_10;
@property (nonatomic, retain) UILabel *saturationLabel;
@property (nonatomic, retain) UILabel *brightnessLabel;

@property (nonatomic, retain) UISlider *numberOfColorsSlider;
@property (nonatomic, retain) UISlider *saturationSlider;
@property (nonatomic, retain) UISlider *brightnessSlider;

- (IBAction) sliderChanged:(id)sender;
- (IBAction) saturationChanged:(id)sender;
- (IBAction) brightnessChanged:(id)sender;

@end
