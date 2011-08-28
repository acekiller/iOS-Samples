/*
     File: MyViewController.m
 Abstract: Main view controller for displaying the image, reflection and slider table.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "MyViewController.h"
#import "QuartzCore/QuartzCore.h" // for CALayer

@interface MyViewController ()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *reflectionView;
@property (nonatomic, retain) UITableView *slidersTableView;

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height;

@end

@implementation MyViewController

@synthesize imageView, reflectionView, slidersTableView;

// image reflection
static const CGFloat kDefaultReflectionFraction = 0.65;
static const CGFloat kDefaultReflectionOpacity = 0.40;
static const NSInteger kSliderTag = 1337;


- (void)viewDidLoad
{
	self.slidersTableView.backgroundColor = [UIColor clearColor];

	self.view.autoresizesSubviews = YES;
	self.view.userInteractionEnabled = YES;
	
	// create the reflection view
	CGRect reflectionRect = imageView.frame;
	
	// the reflection is a fraction of the size of the view being reflected
	reflectionRect.size.height = reflectionRect.size.height * kDefaultReflectionFraction;
	
	// and is offset to be at the bottom of the view being reflected
	reflectionRect = CGRectOffset(reflectionRect, 0, imageView.frame.size.height);
	
	reflectionView = [[UIImageView alloc] initWithFrame:reflectionRect];

	// determine the size of the reflection to create
	NSUInteger reflectionHeight = imageView.bounds.size.height * kDefaultReflectionFraction;
	
	// create the reflection image, assign it to the UIImageView and add the image view to the containerView
	reflectionView.image = [self reflectedImage:imageView withHeight:reflectionHeight];
	reflectionView.alpha = kDefaultReflectionOpacity;
	[self.view addSubview:reflectionView];
}

- (void)viewDidUnload
{
	self.reflectionView = nil;
}

- (void)dealloc
{
	[imageView release];
	[reflectionView release];
	
	[super dealloc];
}


#pragma mark - slider action methods

- (IBAction)sizeSlideAction:(id)sender
{
	UISlider* slider = (UISlider *)sender;
	CGFloat val = [slider value];
	
	// create the reflection view
	CGRect reflectionRect = imageView.frame;
	
	// the reflection is a fraction of the size of the view being reflected
	reflectionRect.size.height = reflectionRect.size.height * val;
	
	// and is offset to be at the bottom of the view being reflected
	reflectionRect = CGRectOffset(reflectionRect, 0.0, imageView.frame.size.height);
	reflectionView.frame = reflectionRect;
	NSUInteger reflectionHeight = imageView.bounds.size.height * val;
	
	// create the reflection image, assign it to the UIImageView and add the image view to the containerView
	reflectionView.image = [self reflectedImage:imageView withHeight:reflectionHeight];
	
	// get the alpha slider value, keep it set on the reflection
	UISlider *alphaSlider = (UISlider *)[[slidersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].contentView viewWithTag:kSliderTag];
	reflectionView.alpha = alphaSlider.value;
	
	[slidersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", val];
}

- (IBAction)alphaSlideAction:(id)sender
{
	UISlider* slider = (UISlider *)sender;
	CGFloat val = [slider value];
	reflectionView.alpha = val;
	
	[slidersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", val];
}


#pragma mark - Image Reflection

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;

	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (nil, pixelsWide, pixelsHigh, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);

    return bitmapContext;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
    if (!height) return nil;
    
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
	
	// offset the context -
	// This is necessary because, by default, the layer created by a view for caching its content is flipped.
	// But when you actually access the layer content and have it rendered it is inverted.  Since we're only creating
	// a context the size of our reflection view (a fraction of the size of the main view) we have to translate the
	// context the delta in size, and render it.
	//
	CGFloat translateVertical= fromImage.bounds.size.height - height;
	CGContextTranslateCTM(mainViewContentContext, 0, -translateVertical);
	
	// render the layer into the bitmap context
	CALayer *layer = fromImage.layer;
	[layer renderInContext:mainViewContentContext];
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGImageRef reflectionImage = CGImageCreateWithMask(mainViewContentBitmapContext, gradientMaskImage);
	CGImageRelease(mainViewContentBitmapContext);
	CGImageRelease(gradientMaskImage);
	
	// convert the finished reflection image to a UIImage 
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"CellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellID] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor blackColor];
        
        UISlider *slider = [[[UISlider alloc] initWithFrame:CGRectMake(cell.contentView.bounds.origin.x + 55.0, 0.0,
																	   cell.contentView.bounds.size.width - 110.0, 40.0)] autorelease];
        slider.tag = kSliderTag;
        [cell.contentView addSubview:slider];
                
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.textColor = [UIColor blackColor];        
	}
    
    UISlider *slider = (UISlider *)[cell.contentView viewWithTag:kSliderTag];
	if (indexPath.row == 0)
	{
		cell.textLabel.text = @"Size";
		slider.value = kDefaultReflectionFraction;
		[slider addTarget:self action:@selector(sizeSlideAction:) forControlEvents:UIControlEventTouchUpInside];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", slider.value];
	}
	else
	{
		cell.textLabel.text = @"Alpha";
		slider.value = kDefaultReflectionOpacity;
		[slider addTarget:self action:@selector(alphaSlideAction:) forControlEvents:UIControlEventValueChanged];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", slider.value];
	}
    
	return cell;
}

@end
