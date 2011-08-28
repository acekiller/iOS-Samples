//
//  FirstViewController.m
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FirstViewController.h"

// プライベートメソッド追加用カテゴリ
@interface FirstViewController (PrivateMethods)

- (void)setNumberOfColorsLabel:(int)number;


@end


@implementation FirstViewController

@synthesize colorCircleView;
@synthesize numberOfColorsLabel_1;
@synthesize numberOfColorsLabel_10;
@synthesize saturationLabel;
@synthesize brightnessLabel;

@synthesize numberOfColorsSlider;
@synthesize saturationSlider;
@synthesize brightnessSlider;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

    [super viewDidLoad];	
	
	// 四角形数スライダー値表示用ラベルの初期設定	
	numberOfColorsLabelArray = [[NSMutableArray alloc] init];
	[numberOfColorsLabelArray addObject:numberOfColorsLabel_1];
	[numberOfColorsLabelArray addObject:numberOfColorsLabel_10];
	UILabel *value;
	for (value in numberOfColorsLabelArray) {
		value.font = [UIFont fontWithName:@"DBLCDTempBlack"
									 size:value.font.pointSize];
	}	
	[self setNumberOfColorsLabel:(int)numberOfColorsSlider.value];
	formerSliderValue = (int)numberOfColorsSlider.value;

	// 彩度スライドバー値表示用ラベル初期設定
	saturationLabel.font = [UIFont fontWithName:@"DBLCDTempBlack"
										   size:saturationLabel.font.pointSize];
	saturationLabel.text = [NSString stringWithFormat:@"%d", (int)saturationSlider.value];
	formerSaturationSliderValue = (int)saturationSlider.value;
	colorCircleView.saturation = (int)saturationSlider.value;
	
	
	// 明度スライドバー値表示用ラベル初期設定
	brightnessLabel.font = [UIFont fontWithName:@"DBLCDTempBlack"
										   size:saturationLabel.font.pointSize]; 
	brightnessLabel.text = [NSString stringWithFormat:@"%d", (int)brightnessSlider.value];
	colorCircleView.brightness = (int)brightnessSlider.value;
	formerBrightSliderValue = (int)brightnessSlider.value;
	colorCircleView.firstViewController = self;
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -

- (IBAction) sliderChanged:(id)sender
{
	// NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	// NSLog(@"slider value = %f", numberOfColorsSlider.value);
	
	if (formerSliderValue != (int)numberOfColorsSlider.value) {
		[self setNumberOfColorsLabel:(int)numberOfColorsSlider.value];
		[numberOfColorsView setNumber:(int)numberOfColorsSlider.value];
		[colorCircleView setNeedsDisplay];
		formerSliderValue = (int)numberOfColorsSlider.value;
	}
	
}

- (IBAction) saturationChanged:(id)sender
{
	// NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	
	// 彩度を設定する
	if (formerSaturationSliderValue != (int)saturationSlider.value) {
		saturationLabel.text = [NSString stringWithFormat:@"%d", (int)saturationSlider.value];
		colorCircleView.saturation = (int)saturationSlider.value;
		formerSaturationSliderValue = (int)saturationSlider.value;
		[colorCircleView setNeedsDisplay];		
	}
}

- (IBAction) brightnessChanged:(id)sender
{
	// NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

	if (formerBrightSliderValue != (int)brightnessSlider.value) {
		brightnessLabel.text = [NSString stringWithFormat:@"%d", (int)brightnessSlider.value];
		colorCircleView.brightness = (int)brightnessSlider.value;
		formerBrightSliderValue = (int)brightnessSlider.value;
		[colorCircleView setNeedsDisplay];
	}
}


#pragma mark -
#pragma mark PrivateMethods

// 0以上に対応
- (void)setNumberOfColorsLabel:(int)number
{
	// NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	
	UILabel *value;
	for (value in numberOfColorsLabelArray) {
		NSLog(@"number = %d", number);
		
		if (number == 0) {
			value.text = @"";
		} else {
			value.text = [NSString stringWithFormat:@"%d", (int)(number % 10)];
		}
		number = number / 10;
	}
	
	UILabel *firstValue = [numberOfColorsLabelArray objectAtIndex:0];
	if (firstValue.text == @"") {
		firstValue.text = @"0";
	}
}

@end
