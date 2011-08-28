    //
//  SecondViewController.m
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"


@implementation SecondViewController

@synthesize colorRSlider;
@synthesize minusRButton;
@synthesize plusRButton;
@synthesize colorGSlider;
@synthesize minusGButon;
@synthesize plusGButton;
@synthesize colorBSlider;
@synthesize minusBButton;
@synthesize plusBButton;

// 値表示用のラベル
@synthesize colorWebValueLabel;
@synthesize colorRValueLabel;
@synthesize colorGValueLabel;
@synthesize colorBValueLabel;

// 描画用のUIView
@synthesize selectedView;

// SampleButton
@synthesize sampleView_1;
@synthesize sampleView_2;
@synthesize sampleView_3;
@synthesize sampleView_4;
@synthesize sampleView_5;
@synthesize sampleView_6;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
	
	// backgroundのカラーをセット(初期値は黒)
	[self setBackgroundColorsWithR:0
								 G:0
								 B:0];

	
	// SampleViewの初期化
	selectedViewInSamples = sampleView_1; // 初期選択Viewは左上のものとする
	colorRGBSelectedImages = [[NSMutableArray alloc] init];
	[colorRGBSelectedImages addObject:sampleView_1];
	[colorRGBSelectedImages addObject:sampleView_2];
	[colorRGBSelectedImages addObject:sampleView_3];
	[colorRGBSelectedImages addObject:sampleView_4];
	[colorRGBSelectedImages addObject:sampleView_5];
	[colorRGBSelectedImages addObject:sampleView_6];
	RGBSelectedImage *value;
	for (value in colorRGBSelectedImages) {
		// 初期の色は白
		value.colorR = 255;
		value.colorB = 255;
		value.colorG = 255;
	}
	
	[self valueChangedByAction];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[colorRGBSelectedImages release];
    [super dealloc];
}

#pragma mark -
- (void)setLabelsWithR:(int)colorR G:(int)colorG B:(int)colorB
{
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

	colorRValueLabel.text = [NSString stringWithFormat:@"%d", colorR];
	colorGValueLabel.text = [NSString stringWithFormat:@"%d", colorG];
	colorBValueLabel.text = [NSString stringWithFormat:@"%d", colorB];
	colorWebValueLabel.text = [NSString stringWithFormat:@"#%02X%02X%02X", colorR, colorG, colorB];
}

- (void)valueChangedByAction
{
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	
	[self setLabelsWithR:(int)colorRSlider.value 
					   G:(int)colorGSlider.value
					   B:(int)colorBSlider.value];
	
	// ViewのRBGをセットする
	[selectedView setColorWithR:colorRSlider.value
							  G:colorGSlider.value
							  B:colorBSlider.value];
	[selectedView setNeedsDisplay];	
	if (selectedViewInSamples != nil) {
		[selectedViewInSamples setColorWithR:colorRSlider.value
										   G:colorGSlider.value
										   B:colorBSlider.value];
		[selectedViewInSamples setNeedsDisplay];		
	} else {
		NSLog(@"backgroundChanged");
		[self setBackgroundColorsWithR:colorRSlider.value
									 G:colorGSlider.value
									 B:colorBSlider.value];
	}

}

- (void)setBackgroundColorsWithR:(int)colorR G:(int)colorG B:(int)colorB
{
	backgroundColorR = colorR;
	backgroundColorG = colorG;
	backgroundColorB = colorB;
	self.view.backgroundColor = [UIColor colorWithRed:backgroundColorR/255.0
												green:backgroundColorG/255.0
												 blue:backgroundColorB/255.0
												alpha:1.0];
	UIColor *labelColor;
	if (colorR + colorG + colorB < 1.5 * 255) {
		labelColor = [UIColor whiteColor];
	} else {
		labelColor = [UIColor blackColor];
	}
	UIView *value;
	for (value in [self.view subviews]) {
		if ([value isKindOfClass:[UILabel class]]) {
			((UILabel*)value).textColor = labelColor;
		}
	}

}

#pragma mark -
#pragma mark IBAction

// RGB用のボタンとスライダーがおされた時
- (IBAction)colorRSliderChanged:(id)sender
{
	[self valueChangedByAction];
}

- (IBAction)minusRButtonPressed:(id)sender
{
	if (colorRSlider.minimumValue < colorRSlider.value && colorRSlider.value <= colorRSlider.maximumValue) {
		colorRSlider.value -= 1;
	}
	
	[self valueChangedByAction];
}

- (IBAction)plusRButtonPressed:(id)sender
{
	if (colorRSlider.minimumValue <= colorRSlider.value && colorRSlider.value < colorRSlider.maximumValue) {
		colorRSlider.value += 1;
	}
	
	[self valueChangedByAction];
}

- (IBAction)colorGSliderChanged:(id)sender
{
	[self valueChangedByAction];
}

- (IBAction)minusGButtonPressed:(id)sender
{
	if (colorGSlider.minimumValue < colorGSlider.value && colorGSlider.value <= colorGSlider.maximumValue) {
		colorGSlider.value -= 1;
	}	
	[self valueChangedByAction];
}

- (IBAction)plusGButtonPressed:(id)sender
{
	if (colorGSlider.minimumValue <= colorGSlider.value && colorGSlider.value < colorGSlider.maximumValue) {
		colorGSlider.value += 1;
	}	
	[self valueChangedByAction];
}

- (IBAction)colorBSliderChanged:(id)sender
{
	[self valueChangedByAction];
}

- (IBAction)minusBButtonPressed:(id)sender
{
	if (colorBSlider.minimumValue < colorBSlider.value && colorBSlider.value <= colorBSlider.maximumValue) {
		colorBSlider.value -= 1;
	}	
	[self valueChangedByAction];
}

- (IBAction)plusBButtonPressed:(id)sender
{
	if (colorBSlider.minimumValue <= colorBSlider.value && colorBSlider.value < colorBSlider.maximumValue) {
		colorBSlider.value += 1;
	}	
	[self valueChangedByAction];
}

#pragma mark -
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);
	
	CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
	NSLog(@"touchPoint(x,y) = (%f,%f)", touchPoint.x, touchPoint.y);
	
	RGBSelectedImage *value;
	BOOL flagContains = NO;
	for (value in colorRGBSelectedImages) {
		if (CGRectContainsPoint(value.frame, touchPoint)) {
			NSLog(@"contains!");
			flagContains = YES;
			value.selected = YES;
			selectedViewInSamples = value;
		} else {
			value.selected = NO;
			[value setNeedsDisplay];
		}
	}
	// もしタッチされたところにViewがなかったら
	if (flagContains == NO) {
		if (CGRectContainsPoint(CGRectMake(0, 0, kDisplayWidth, 300), touchPoint)) {
			selectedViewInSamples = nil;
		}else {
			selectedViewInSamples.selected = YES;
			// selectedViewInSamples = nil;
		}
	}
	
	[self selectedViewChanged];
	
	NSLog(@"frame(x, y) = (%f, %f)", sampleView_1.frame.origin.x, sampleView_1.frame.origin.y);

}

- (void)selectedViewChanged
{
	// サンプルViewをSelectされたViewと同じにする
	if (selectedViewInSamples != nil) {
		// ６つのViewのどれかが選択されたとき
		[selectedView setColorWithR:selectedViewInSamples.colorR
								  G:selectedViewInSamples.colorG
								  B:selectedViewInSamples.colorB];		
	} else {
		// backgroundが選択されたとき
		[selectedView setColorWithR:backgroundColorR
								  G:backgroundColorG
								  B:backgroundColorB];
	}

	// サンプルViewを再描画
	[selectedView setNeedsDisplay];
	
	// Selectされたものも再描画(外枠の色を変えるため)
	[selectedViewInSamples setNeedsDisplay];
	
	
	// スライダーの値をSelectされたものと同じにする
	colorRSlider.value = selectedView.colorR;
	colorGSlider.value = selectedView.colorG;
	colorBSlider.value = selectedView.colorB;
	
	[self valueChangedByAction];
}

@end
