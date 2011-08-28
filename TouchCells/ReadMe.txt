TouchCells

Demonstrates how to implement trackable-settable UIControls embedded in a UITableView. This approach is handy if an application already uses its accessory view to the right of the table cell, but still wants a check mark view that supports toggling states of individual row items. The green check mark on the left provides this need which is trackable (checked/unchecked) independent of table selection. This is a similar user interface to that of Mail's Inbox table where mail items can be individually checked and unchecked for deletion.It implements a custom UITableViewCell and embeds a UIButton of type "UIButtonTypeCustom". The button has a target/action so that its appearance can be changed from checked to unchecked. The check/uncheck state is stored as a BOOL property inside the custom UITableViewCell, available for the table view controller. If an entire table row is touched, the delegate "didSelectRowAtIndexPath" will call the action method of that cell's button.Build Requirements
Mac OS X 10.5.6 or later, Xcode 3.1.3, iPhone OS 3.0 or later.


Runtime Requirements
Mac OS X 10.5.6 or later, iPhone OS 3.0 or later.


Using the Sample
Launch the TouchCells project using Xcode 3.1.3 or later.

To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting. When launched, touch the check mark on the left of each table row to make it appear checked, touch again to uncheck it. Optionally you can select the entire row to check that item as well.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application's delegate to setup its window and content.
MyTableViewController.h/.m - The main UITableViewController.
DetailViewController.h/.m - A separate detail screen used to respond to taps of the accessory to the right.
CustomCell.h/.m - A subclass of UITableViewCell containing the UIButton for its checked/unchecked state.


Changes from Previous Versions
1.0 - First release.
1.1 - Fixed bug in that selection did not change NSArray data source; data source now originates from a plist.
1.2 - Adopted iPhone OS 3.0 UITableView and UITableViewCell APIs.

Copyright (C) 2008-2009 Apple Inc. All rights reserved.