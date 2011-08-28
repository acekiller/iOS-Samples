NavBar

Demonstrates how to use UINavigationController and UIViewController classes together as building blocks to your application's user interface.  Use it as a launching pad in starting the development of your new application.  The various pages in this sample exhibit different ways in how to modify the navigation bar by modifying the navigation controller's UINavigationItem.  This class represents the navigation bar at the top of the screen.  Among the levels of customization are varying appearance styles known as UIBarStyle, and applying custom left and right buttons known as UIBarButtonItems.

In addition, this sample shows a technique in how to manage multiple nib files on one application.  Each page or UIViewController contains its own nib and is loaded using:

	- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

Build Requirements
Mac OS X 10.5.6 or later, iPhone SDK 3.0

Runtime Requirements
Mac OS X 10.5.6 or later, iPhone SDK 3.0

Using the Sample
Build and run the sample using Xcode 3.1. To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting.

Bar Style
Click the "Style" button to the left of the main page to change the navigation bar's style or UIBarStyle.   This will take you to an action sheet where you can change the background's appearance (default, black-opaque, or black-translucent).

View One
This page adds a titled UIButton of type UIButtonTypeNavigation to the right button view of the navigation bar.

View Two
This page adds a UIButton of type UIButtonTypeNavigation to the right button view of the navigation bar, but with a UIImage instead of text.

View Three
This page adds a UISegmentedControl to the right button view of the navigation bar.

View Four
This page adds a UISegmentedControl as the custom title view (center) of the navigation bar.

View Five
This page adds a UISegmentedControl as the custom title view (center) of the navigation bar plus a prompt string.

Info Button
Presents a UIViewController as a modal type-view covering the entire screen.

Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application's delegate to setup its window and content.
MainViewController.h/.m - The front UIViewController containing a table to navigate to all its views.

PageOneViewController.h/.m - Page one of customizing the navigation bar's right button view.
PageTwoViewController.h/.m - Page two of customizing the navigation bar's right button view with an image.
PageThreeViewController.h/.m - Page three of customizing the navigation bar's left and right views.
PageFourViewController.h/.m - Page four of customizing the navigation bar's title view.
PageFiveViewController.h/.m - Page five of customizing the navigation bar's title view and prompt.
ModalViewController.h/.m - Page presented as a modal view controller.

Changes from Previous Versions
1.0 - First release
1.1 - Minor update to the latest SDK API changes.
1.2 - Updated for Beta 3: reusable UITableView cells, added new use of UIViewController "presentModalViewController".
1.3 - Updated for Beta 4, changed to use Interface Builder xib file.
1.4 - Updated for Beta 5: changes to UITableViewDelegate, upgraded to use xib files for each UIViewController.
1.5 - Beta 6 Release, minor UI improvements.
1.6 - Changed bundle identifier.
1.7 - Updated for and tested with iPhone OS 2.0. First public release.
1.8 - Upgraded for 3.0 SDK due to deprecated APIs; in "cellForRowAtIndexPath" it now uses UITableViewCell's initWithStyle. Now uses viewDidUnload.

Copyright (C) 2008-2009 Apple Inc. All rights reserved.