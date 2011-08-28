DrillDownSave

Demonstrates how to restore the user's current location in a drill-down list style user interface and
restore that location when the app is relaunched. The drill-down or content hierarchy is generated
from a plist file called 'outline.plist'.

The sample stores the user's location in its preferences file using NSUserDefaults.

One important factor this sample illustrates in restoring the proper UIViewController stack by
telling its UINavigationController to push each level without animation like so:

	[[self navigationController] pushViewController:level3ViewController animated:NO];


Build Requirements
Mac OS X 10.5.6, iPhone SDK 3.0


Runtime Requirements
Mac OS X 10.5.6, iPhone SDK 3.0


Using the Sample
Build and run DrillDownSave using Xcode. To run in the simulator, set the Active SDK to Simulator.
To run on a device, set the Active SDK to the appropriate Device setting.
When launched navigate through various items in the tree hierarchy.  Press the home button and re-launch DrillDownSave.
The app should return you to the same level from the previous launch.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application' delegate to setup its window and content.
Level1ViewController.h/.m - The top-most view controller of the tree hierarchy.
Level2ViewController.h/.m - The second level view controller of the tree hierarchy.
Level3ViewController.h/.m - The third and last level view controller of the tree hierarchy.
LeafViewController.h/.m - Leaf item view controller for items residing at level 3.
outline.plist - the dictionary or outline of the view level hierarchy used in populating the drill-down list.


Changes from Previous Versions
1.0 - First release
1.1 - Updated for and tested with iPhone OS 2.0. First public release.
1.2 - Upgraded for 3.0 SDK due to deprecated APIs; in "cellForRowAtIndexPath" it now uses UITableViewCell's initWithStyle.

Copyright (C) 2008-2009 Apple Inc. All rights reserved.