
### WhichWayIsUp ###

===========================================================================
DESCRIPTION:

The WhichWayIsUp sample application demonstrates how to use a UIViewController to track the orientation of the device. The application draws a small wooden crate that maintains the correct orientation as the user rotates the device.

After the application launches, the user can rotate the device to portrait, landscape right or left, and portrait upside down, and the box remains upright in relation to the floor. If you run the application in the simulator, rotate the device using the Hardware menu items.

===========================================================================
BUILD REQUIREMENTS:

Mac OS X 10.5.3, Xcode 3.1, iPhone OS 2.0

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X 10.5.3, iPhone OS 2.0

===========================================================================
PACKAGING LIST:

WhichWayIsUpAppDelegate.h
WhichWayIsUpAppDelegate.m
A simple UIApplication delegate class that adds the CreateViewController's view to the window as subview.

CrateViewController.h
CrateViewController.m
This UIViewController subclass overrides the inherited shouldAutorotateToInterfaceOrientation: method so that the crate image can respond to device rotation. The CrateViewController manages two views that are set up in the MainWindow.xib file. The first view is a container that fills the entire screen and resizes as the device orientation changes. The second view is a UIImageView that displays the crate image. The image view is positioned in the center of the container view and its autoresizingMask property is set to keep the crate the same size at all times.

MainWindow.xib
Interface Builder 'nib' file that defines the interface for the application. By opening and examining this file in Interface Builder, you can see how the CrateViewController's outlets are set and its views configured. Use Interface Builder's Inspector window to see how the views' autoresizingMask properties are set to allow the crate to rotate without distortion of the image. 

main.m
Entry point for the application. Creates the application object and causes the event loop to start.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.7
- Updated for and tested with iPhone OS 2.0. First public release.

Version 1.6
- Made nib file localizable.

Version 1.5
- Updated for Beta 6.
- Fixed missing app icon (case mismatch).
- General code clean-up.
- Added LSRequiresIPhoneOS setting to Info.plist

Version 1.4
- Updated for Beta 5.
- Converted sample to use Xcode's Cocoa Touch Application project template.

Version 1.3
- Updated for Beta 4.
- Updated build settings.
- Updated ReadMe file format.

Version 1.2
- Updated for Beta 3.
- Replaced the icon and Default.png images.

Version 1.1 
- Updated for Beta 2. 

===========================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.