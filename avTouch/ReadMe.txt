avTouch

===========================================================================
DESCRIPTION:

avTouch demonstrates basic use of AVFoundation, Core Animation, and Core Graphics Services on the iPhone for basic playback of audio files.

The code in avTouch uses AVFoundation to play an audio file containing AAC audio data. The application uses CoreGraphics and OpenGL to display volume meters for the audio being played.

This application shows how to:

	* Create an AVAudioPlayer object from an input audio file.
	* Use OpenGL and CoreGraphics to display metering levels.
	* Use Audio Session Services to set an appropriate audio session category for playback.
	* Use AVFoundation's interruption delegate to pause playback upon receiving an interruption, and to then resume playback if the interruption ends.

avTouch does not demonstrate how to play multiple files, nor does it provide more advanced AVFoundation usage. 


===========================================================================
RELATED INFORMATION:

Core Audio Overview, November 2008


===========================================================================
SPECIAL CONSIDERATIONS:

none

===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.5.5, Xcode 3.1, iPhone OS 2.2, iPhone SDK for iPhone OS 2.2 and later


===========================================================================
RUNTIME REQUIREMENTS:

Simulator: Mac OS X v10.5.5, iPhone SDK 2.2 and later
iPhone: iPhone OS 2.2


===========================================================================
PACKAGING LIST:

CALevelMeter.h
CALevelMeter.mm

The CALevelMeter class defines the level meter view for the applcation, displaying the metering data from an AVAudioPlayer object

LevelMeter.h
LevelMeter.m

LevelMeter is a base metering class, providing simple functionality for displaying level data

GLLevelMeter.h
GLLevelMeter.m

GLLevelMeter is a subclass of LevelMeter that uses OpenGL for drawing

avTouchAppDelegate.h
avTouchAppDelegate.m

The avTouchAppDelegate class defines the application delegate object, responsible for adding the application's view to the application window.


avTouchViewController.h
avTouchViewController.m

The avTouchViewController class defines the view controller, responsible for handling rotations

avTouchController.h
avTouchController.m

The avTouchController defines the main controller class, responsible for managing the AVAudioPlayer object and handling user input

================================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.