### TopPaid ###

===========================================================================
DESCRIPTION:

This sample demonstrates how to design and build a universal application capable of running on both the iPhone and iPad.  It shows the steps needed to make an existing iPhone application universal by introducing two unique user interface designs for both devices, yet using the same data model.

The sample itself shows a multi-stage approach to loading and displaying a UITableView.  It begins by loading the relevant text from an RSS feed so the table can load as quickly as possible, and then downloads the images for each row asynchronously so the UI is more responsive.

There are two projects in this sample: TopPaid.start and TopPaid.universal.  It is strongly encouraged that you look over the "start" application first, and get to know it's design and classes.  Then examine the included document "DesignDiagram.pdf" which describes the general structure of the additional "universal" version.

It is also encouraged that you read the "iPad Programming Guide".


===========================================================================
BUILDING YOUR UNIVERSAL APPLICATION:

When upgrading your application to "universal", you need to take into consideration several things:

¥ Revisiting your Model-View-Controller structure of your application.
Since you are supporting two devices, you will have to factor out two separate view designs apart for each device.  This will mean different UI layouts between iPhone and iPad or multiple nibs supporting them.

¥ Grouping shared code and resources and then separate out specific iPad and iPhone code and resources.  This is mostly an organizational effort you go through in Xcode to keep things well organized.

¥ Any place you programmatically allocate instances of classes found only in the 3.2 SDK, you should use NSClassFromString() to reach them.  The dynamic nature of Objective-C makes it possible to avoid using linked symbols for class names by creating an instance of a class using the NSClassFromString() function.  Refer to the "iPad Programming Guide" section: "Adding Runtime Checks for Newer Symbols" which describes how to use this technique.  This will allow your code to survive the runtime checks when creating for example a "UIPopoverViewController".  This sample shows how you can do that.

Xcode Project
=============================================
1) Set the base SDK to 3.2
2) Set the deployment target to 3.1.3 (so it can run on the iPhone 3.1.3)
3) Set "Target Device Family" to be "iPhone/iPad"

Default Images
=============================================
4) Since we are supporting both kinds of devices, you need to define two sets of default launch images files.  In your Info.plist file add the following:

For iPhone -
<key>UISupportedInterfaceOrientations</key>
<string>UIInterfaceOrientationPortrait</string>

Include you already existing "Default.png" file in your project.

For iPad -
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>

Add new default images for the iPad.  In this sample we use:
	Default-Landscape.png


===========================================================================
BUILD REQUIREMENTS:

iPhone SDK 3.2


===========================================================================
RUNTIME REQUIREMENTS:

iPhone OS 3.2 for iPad
iPhone OS 3.1.3 for iPhone


===========================================================================
PACKAGING LIST:

The following sources are shared between both iPhone and iPad devices -

AppDelegate.{h/m} -
    The app delegate class that downloads in the background the
    "Top Paid iPhone Apps" RSS feed using NSURLConnection.

AppRecord.{h/m} -
    Wrapper object for each data entry, corresponding to a row in the table.

AppListViewController.{h/m} -
    UITableViewController subclass that builds the table view in multiple stages,
    using feed data obtained from the LazyTableAppDelegate.

ParseOperation.{h/m}
    Helper NSOperation object used to parse the XML RSS feed loaded by LazyTableAppDelegate.

IconDownloader.{h/m}
    Helper object for managing the downloading of a particular app's icon.
    As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
    yet exist and works in conjunction with the RootViewController to manage which apps need their icon.

ContentController.{h/m}
    The generic content controller superclass. Subclasses are created for supporting differing devices.
    The controller object responsible for loading and controlling the user interface and object model.
    Typically in the past, this would be a part of the AppDelegate, but splitting it out as a separate controller
    helps manage the support of both iPhone and iPad.

ContentController_iPhone.{h/m}
    Content controller used to manage the navigation controller for the iPhone.

ContentController_iPad.{h/m}
    Content controller used to manage the split view controller and its master popover for the iPad.

DetailViewController.{h/m}
    Detail view showing more extended information running only for the iPad.


===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

===========================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.