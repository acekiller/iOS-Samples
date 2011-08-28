TableSearch

This sample demonstrates how to use the UISearchDisplayController object in conjunction with a UISearchBar, effectively filtering in and out the contents of that table. If an iPhone/iPod Touch application has large amounts of table data, this sample shows how to filter it down to a manageable amount if memory usage is a concern or you just want users to scroll through less content in a table.

It shows how you can:
- Create a UISearchDisplayController.
- Use the new scopes on UISearchBar with a search display controller.
- Manage the interaction between the search display controller and a containing UINavigationController
	(there is no code for this -- the navigation bar is moved around as necessary).
- Return different results for the main table view and the search display controller's table view.
- Handle the destruction and re-creation of a search display controller when receiving a memory warning.


Build Requirements
iPhone SDK 3.0 or later.


Runtime Requirements
iPhone OS 3.0 or later.


Using the Sample
Build and run TableSearch using Xcode. To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting.  When launched tap the search field and as you enter case insensitive text the list shinks/expands based on the filter text. An empty string will show the entire contents.  To get back the entire contents once you have filtered the content, touch the search bar again, click the clear ('x') button and hit cancel.


Packaging List
AppDelegate.{h,m} - The application's delegate to setup its window and content.
MainViewController.{h,m} - Manages a table view to display a list of products, and manages a search bar to filter the product list.
Product.{h,m} - A simple model file to represent a product with a name and type.
main.m - Main source file for this sample.


Changes from Previous Versions
1.4 - Fixed problem with saving state during low memory warnings.
1.3 - Updated UISearchBar and UISearchDisplayController as nib objects.
1.2 - Upgraded to use UISearchDisplayController and iPhone OS 3.0.
1.1 - Minor user interface upgrades, no longer using UINavigationController; UISearchBar takes it's place.
1.0 - Updated for and tested with iPhone OS 2.0. First public release.


Copyright (C) 2008-2010 Apple Inc. All rights reserved.