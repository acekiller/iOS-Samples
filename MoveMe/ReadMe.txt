### MoveMe ###

================================================================================
DESCRIPTION:

This application illustrates simple drawing, touch handling, and animation using UIKit and Core Animation.

The main class of interest is MoveMeView.  An instance of MoveMeView is created in the MainWindow nib file as a subview of the window.  MoveMeView creates an instance of PlacardView which displays text superimposed over an image, and adds the placard view as a subview of itself.
If you touch inside the placard, the placard is animated in two ways: its transform is changed such that it appears to pulse, and it is moved such that its center is directly under the touch.
If you move your finger, MoveMeView moves the placard so that it remains centered under the touch. When the touch ends, the placard is animated back to the center of the screen, and its original (identity) transform restored.

The UIView methods implemented by MoveMeView that relate to touch handling are:

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event

These in turn invoke other methods to perform the animation.  The sample illustrates two forms of animation:

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint shows you how to use UIView's built-in animation with a delegate.  Two slightly different implementations are provided to illustrate different animation behaviors.

- (void)animatePlacardViewToCenter shows how to implement explicit animation using CAKeyframeAnimation.

Further details are given in comments in the code.


================================================================================
BUILD REQUIREMENTS:

Mac OS X 10.5.7, Xcode 3.1, iPhone OS 3.0

================================================================================
RUNTIME REQUIREMENTS:

Mac OS X 10.5.7, iPhone OS 3.0

================================================================================
PACKAGING LIST:

Classes/MoveMeAppDelegate.h
Classes/MoveMeAppDelegate.m
Simple application delegate that sets up a window and view controller.

Classes/MoveMeView.h
Classes/MoveMeView.m
Contains a (placard) view that can be moved by touch. Illustrates handling touches and two styles of animation.

Classes/PlacardView.h
Classes/PlacardView.m
Displays a UIImage with text superimposed.

================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 2.7
- Corrected a memory leak where a CGPath was not released.

Version 2.6
- Updated for and tested with iPhone OS 2.0. First public release.

Version 2.5
- Updated the bundle identifier.

Version 2.4
- Updated for Beta 6.
- Added LSRequiresIPhoneOS flag to Info.plist file.
- Added touchesCanceled method to MoveMeView.
- Updated the Default image.

Version 2.3
- Updated for Beta 5.
- Moved the MoveMeView to a separate nib file; added a view controller to manage the view.
- The window is now displayed by the application delegate.

Version 2.2
- Updated for Beta 4.
- Minor change to artwork.
- The application window is displayed using the Visible At Launch flag in the MainWindow xib file (previously it was sent makeKeyAndVisible in applicationDidFinishLaunching:).
- The bounce animation path is changed.

Version 2.1
- Updated for Beta 3
- Updated to use a nib file to create the application window and the instance of MoveMeView.

================================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.
