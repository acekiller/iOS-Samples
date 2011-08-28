AlternateViews
==============

A sample app that demonstrates how to implement alternate or distinguishing view controllers for each
particular device orientation.  Through the help of the following UIViewController properties,
this can be easily achieved -

	@property(nonatomic,assign) UIModalTransitionStyle modalTransitionStyle;	// for a transition fade
	@property(nonatomic,assign) BOOL wantsFullScreenLayout;   // for any view controller to appear over another

This sample implements a two different view controllers one for portrait and one for landscape.
The portrait view controller listens for device orientations in order to properly swap in and out the
landscape view controller.  It uses the above two properties to achieve the visual cross-fade effect.


Build Requirements
Mac OS X 10.5.6 or later, iPhone SDK 3.0


Runtime Requirements
Mac OS X 10.5.6 or later, iPhone SDK 3.0


Using the Sample
Build and run the sample using Xcode 3.1.3. To run in the simulator, set the Active SDK to Simulator.
To run on a device, set the Active SDK to the appropriate Device setting.  When launched, notice the
view says "Portrait".  Rotate the device to landscape right or landscape left positions and the view
changes to the alternate one supporting landscape.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application's delegate to setup its window and content.

PortraitViewController.h/.m - The secondary UIViewController for portrait device orientation.
LandscapeViewController.h/.m - The main UIViewController for landscape device orientation.


Changes from Previous Versions
1.0 - First release

Copyright (C) 2009 Apple Inc. All rights reserved.