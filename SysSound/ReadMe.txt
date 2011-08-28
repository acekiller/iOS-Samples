SysSound

===========================================================================
DESCRIPTION:

SysSound demonstrates basic use of System Sound Services (declared in AudioToolbox/AudioServices.h) for playing short sounds and invoking vibration.


     NOTE: System Sound Services is intended for user-interface 
	 sound effects and user alerts. It is not intended for sound 
	 effects in games. 


The code includes three playback methods.

* One method uses the AudioServicesPlaySystemSound function to play a system sound in response to a button tap.

* A second method uses the AudioServicesPlayAlertSound function to play the same system sound, but as an alert. On the iPhone, this function simultaneously invokes vibration if the user has configured the "Ring" settings to include vibration. On the iPod touch, this function invokes an alert melody, using the piezoelectric transducer, in lieu of the specified sound file. 

* A third method uses the AudioServicesPlaySystemSound function to explicitly invoke vibration on the iPhone in response to a button tap. It does this by passing the vibration constant rather than a system sound object. 

To create a system sound object for playback, you first create a CFURLRef object that points to the sound file you want to play. SysSound shows how to do this, and also demonstrates where in the file system you should place sound files.

SysSound does not demonstrate using system sound object properties or how to use the sound completion callback.

 
===========================================================================
RELATED INFORMATION:

Core Audio Overview, July 2008
System Sound Services Reference, September 2008


===========================================================================
SPECIAL CONSIDERATIONS:

iPhone OS ignores the vibration constant when running on an iPod touch. Specifically, calling the AudioServicesPlaySystemSound function with the vibration constant on an iPod touch does nothing. Also, because an iPod touch has no speaker, playing a system sound is audible only when using headphones.

In the Simulator, clicking the Vibrate button in the application's user interface does nothing.


===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.5.4, Xcode 3.1, iPhone OS 2.0


===========================================================================
RUNTIME REQUIREMENTS:

Simulator: Mac OS X v10.5.4
iPhone: iPhone OS 2.0


===========================================================================
PACKAGING LIST:

SysSoundAppDelegate.h
SysSoundAppDelegate.m

The SysSoundAppDelegate class defines the application delegate object, responsible for instantiating the controller object (defined in the SysSoundViewController class) and adding the application's view to the application window.

SysSoundViewController.h
SysSoundViewController.m

The SysSoundViewController class defines the controller object for the application. The object helps set up the user interface, responds to and manages user interaction, and implements sound playback and vibration.


===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0, tested with iPhone OS 2.0. First public release.


================================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.