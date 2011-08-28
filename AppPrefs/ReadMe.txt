AppPrefs

Demonstrates how to display your app's preferences or settings in the "Settings" system application.
A settings bundle, included in your application’s bundle directory, contains the information needed by
the Settings application to display your preferences and make it possible for the user to modify them.
It then saves any configured values in the defaults database so that your application can retrieve them at runtime. 

This sample offers an Xcode project already pre-configured to build your Settings bundle as a target.
To customize your settings UI, change the Root.plist file.


Build Requirements
iPhone OS 3.0.


Runtime Requirements
iPhone OS 3.0.


Using the Sample
Launch the AppPrefs project using Xcode.
Make sure the project's current target is set to "AppPrefs".
Build and run the "AppPrefs" target.

To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to
the appropriate Device setting.  When launched notice the text, its color and the view's background color.
Quit the application and launch "Settings".  At the end of the settings list you will find a section
for "AppPrefs".  From there you can set the first and last name, its color and the app's background color.
Quit Settings and return to AppPrefs and notice the settings have changed.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application' delegate to setup its window and content.
MyViewController.h/.m - The main UIViewController containing the app's user interface.
Root.plist - The scheme file for your settings bundle.


Further Information
For more information on extending the Settings application, refer to the "iPhone Application Programming Guide".


Changes from Previous Versions
1.0 - First release
1.1 - Updated for and tested with iPhone OS 2.0. First public release.
1.2 - Updated Read Me
1.3 - More use of nibs, upgraded for 3.0 SDK due to deprecated APIs; in "cellForRowAtIndexPath" it now uses UITableViewCell's initWithStyle.  Settings.bundle no longer builds as a separate Xcode target.

Copyright (C) 2008-2009 Apple Inc. All rights reserved.