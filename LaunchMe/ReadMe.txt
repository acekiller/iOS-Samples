### LaunchMe ###

================================================================================
DESCRIPTION:

The LaunchMe sample application demonstrates how to register a new URL type. Registering a new URL type allows other applications to interact with yours. This sample also shows how to handle an incoming openURL: message from another application. When servicing an openURL: message from another application, you must be very careful to validate the URL in the message before allowing your application to proceed. After you build and run LaunchMe, it displays a dialog with instructions on how to use the application.

================================================================================
BUILD REQUIREMENTS:

Mac OS X 10.5.3, Xcode 3.1, iPhone OS 2.0

================================================================================
RUNTIME REQUIREMENTS:
Mac OS X 10.5.3, iPhone OS 2.0

================================================================================
PACKAGING LIST:

LaunchMeAppDelegate.h
LaunchMeAppDelegate.m
The controller for the application. Handles incoming URL requests.

================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.5
- Updated for and tested with iPhone OS 2.0. First public release.

Version 1.4
- Updated for Beta 6.
- Added LSRequiresIPhoneOS key to Info.plist.

Version 1.3
- Updated for Beta 4.

Version 1.2
- Added code signing.
 
Version 1.1 
- Updated for Beta 3.

================================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.