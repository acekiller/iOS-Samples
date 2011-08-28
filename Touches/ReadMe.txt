### Touches ###

================================================================================
DESCRIPTION:

The Touches  sample application demonstrates how to handle touches, including multiple touches that move multiple objects.  After the application launches, three colored pieces appear onscreen that the user can move independently. Touches cause up to three lines of text to be displayed at the top of the screen.

The top line displays the touch phase for the current touch event: touches began, touches moved, or touches ended.

The second line displays the number of touches that are being tracked by the current event. Keep in mind that this number can change quickly if the user is initiating and ending multiple touch events.

The third line displays  information about multiple taps. The number of taps appear when the user taps two or more times quickly in succession.

To try out the sample, open Touches in Xcode and build and run it. To run in iPhone Simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting.

To get an idea of how touch handling works, trying moving just one piece and observe the phase changes. Next, investigate how taps work by touching the screen twice in succession, first slowly and then with increasing frequency until the touches are registered as taps.

After you see how single touches work, try moving more than one piece. The application reports how many touches it's tracking. Note that the application also tracks touches that are not within a piece.

If you drag one piece over another, the top piece "captures" the piece below, hiding it. This demonstrates how, with one touch, you can drag multiple items. If you want to "unstick" pieces, double tap anywhere on the background (not on the pieces).

Before your application can handle multiple events, it must enable them, either by setting the flag in Interface Builder, or by calling setMultipleTouchEnabled:. The methods touchesBegan:withEvent:, touchesMoved:withEvent:, touchesEnded:withEvent: show how to handle each phase of a multiple touch event. By looking at the code, you'll see that to handle multiple touches at the same time, you need to iterate through all the touch objects passed to each of the touch handling methods, handling each touch separately. Touches does this by calling a "dispatch" method that checks to see which piece the touch is in, and the takes the appropriate action. 

Touches is based on the Cocoa Touch Application template, which provides a starting point for most applications that need a UIView subclass that responds to touches. 

================================================================================
BUILD REQUIREMENTS:

iPhone SDK 3.0

================================================================================
RUNTIME REQUIREMENTS:

iPhone OS 3.0

================================================================================
PACKAGING LIST:

Main.m
The main entry point for the Touches application.

TouchesAppDelegate.h
TouchesAppDelegate.m
The UIApplication  delegate. On start up, this object receives the applicationDidFinishLaunching: delegate message and creates an instance of MyView, which in turn brings up the user interface.

MyView.h
MyView.m
This view implements the touches... methods that respond to user interaction. MyView animates and moves pieces onscreen in response to touch events. It also displays text that shows the touch phase and other information about touches.

================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.8
-Now uses nibs for view creation. Status bar is now displayed on launch. Project updated to use the iPhone 3.0 SDK.

Version 1.7
-Updated for and tested with iPhone OS 2.0. First public release.

Version 1.6
-Updated the application description to match previous changes to the code.
-Edited comments in some of the source files.
-There are no code changes in the version.	

Version 1.5
-Changed the status bar to black to match the background of the application.
-Changed the text layout on the screen; revised the wording.
-Updated the build and runtime requirements.

Version 1.4
-Updated for Beta 5.
-Removed the code for displaying swipe information. This information is no longer available in a touch object.
-Implemented touchesCanceled:withEvent

Version 1.3
-Updated for Beta 4.
-Touches is now built on the Cocoa Touch Application template in Xcode. The application now uses a xib file for setting up the interface. The code that performed window setup was removed. The GestureView is in the xib file, so that view is now initialized through initWithCoder:
-Added code signing settings.
-Fixed text spacing to account for the origin of the superview frame.

Version 1.2
-Added an application icon. 
-Added a Default.png image.
-There are no code changes in this version.

Version 1.1 
-Updated for Beta 2.
-Updated the code to use the locationInView: method of UITouch, which was recently added to 
replace the locationInView property.

================================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.
