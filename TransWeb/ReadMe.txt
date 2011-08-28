TransWeb

Demonstrates how to implement UIWebView with a transparent background.To achieve this you need to make the HTML body's background color transparent by doing the following -
1) set the UIWebView's backgroundColor property to [UIColor clearColor]
2) use the UIWebView's content in the html: <body style="background-color: transparent">
3) the UIWebView's opaque property set to NO
Build Requirements
Mac OS X 10.5.3, Xcode 3.1, iPhone OS 2.0.


Runtime Requirements
Mac OS X 10.5.3, iPhone OS 2.0.


Using the Sample
Launch the TransWeb project using Xcode 3.1.

To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting.  When launched scroll vertically through the web content and observe the transparent background image.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application's delegate to setup its window and view controller content.
MyViewController.h/.m - The main view controller controlling the web view.


Changes from Previous Versions
1.0 - First release.


Copyright (C) 2009 Apple Inc. All rights reserved.