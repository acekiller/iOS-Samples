Reflection

This sample shows how to implement a "reflection" special effect on a given UIImageView most commonly seem in iTunes and iPod player apps.
It allows the rendering effect with "dynamic" input values for 1) reflection height and 2) translucency level.  These values can be plugged into the factory methods provided by this sample to achieve a desired affect.

This sample implements a UIImageView and programmtically builds a "reflection" image view below it using CoreGraphics.  Essentially it builds the reflection using a combination of CGContextRef, CGImageRef and CALayer to do the desired rendering.

The main entry method in creating the reflected image is -

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height;

So you would assign the image to a UIImageView and set its alpha value like so -

reflectionView.image = [self reflectedImage:imageView withHeight:reflectionHeight];
reflectionView.alpha = 0.50;


Build Requirements
Mac OS X 10.5.6, iPhone OS SDK 3.0.


Runtime Requirements
Mac OS X 10.5.6, iPhone OS SDK 3.0.


Using the Sample
Build and run the sample using Xcode. To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting.

When launched, use the two sliders at the bottom to adjust the size and translucency or alpha values of the reflection.  These two values range from 0.0 to 1.0.  The slider values are displayed to the right.  You can use these values by plugging them into the methods that generate the desired reflection effect.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application's delegate to setup its window and content.
MyViewController.h/.m - The main UIViewController containing a the UIImageView and its reflection.


Changes from Previous Versions
1.2 - Fixed a memory leak in CreateGradientImage.
1.1 - Updated to use iPhone 3.0 table cell styles. Fixed an error when reflection height was 0;
1.0 - first release

Copyright © 2008-2009 Apple Inc. All rights reserved.