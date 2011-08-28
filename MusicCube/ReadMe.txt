MusicCube

===========================================================================
DESCRIPTION:

MusicCube demonstrates basic use of OpenGL ES, OpenAL, Audio File Services on the iPhone for manipulating sound in a 3D environment.

The application uses 
	* OpenGL ES to draws 2D and 3D objects
	* OpenAL to play an audio file containing uncompressed (PCM) audio data
	* Audio File Services to manage audio file data reading, and interruptions (as described in Core Audio Overview)

This application shows how to:
	* Draw 2D and 3D objects using OpenGL ES vertex arrays and textures.
	* Set up the environment for OpenAL usage by creating oalDevice and oalContext objects.
	* Read data from an audio file using the ExtendedAudioFile API and attach into an OpenAL buffer object.
	* Create an OpenAL source object and attach a buffer object to it.
	* Update in OpenGL ES code various properties of OpenAL source and listener objects.
	* Use Audio Session Services to register an interruption callback.
	* Use Audio Session Services to set appropriate audio session categories for recording and playback.
	* Use Audio Session Services to pause playback upon receiving an interruption, and to then resume playback if the interruption ends.
	* Create buttons with OpenGL ES textures and handle touches.

MusicCube does not demonstrate how to play multiple source objects, nor does it provide more advanced OpenAL usage. 


===========================================================================
UI FLOW

In our sound stage, the cube represents an omnidirectional sound source, and the teapot represents a sound listener. 
The four modes in the application illustrate how the sound volume and balance will change based on the position of the omnidirectional sound source and the position and rotation of the listener. You can choose one of the four modes by tapping on the numbers 1-4.
	1. Constant sound
	2. Sound variates corresponding to the listener's position changes relative to the source
	3. Sound variates corresponding to the listener's rotation changes relative to the source
	4. Sound variates corresponding to the listener's position and rotation changes relative to the source


===========================================================================
RELATED INFORMATION:

Core Audio Overview, June 2008


===========================================================================
SPECIAL CONSIDERATIONS:

MusicCube demonstrates use of the OpenAL framework for positional audio, and as such is best suited for a stereo listening environment (headphones, external speakers, etc.)


===========================================================================
BUILD REQUIREMENTS:

iPhone SDK 3.1 and later


===========================================================================
RUNTIME REQUIREMENTS:

iPhone OS 3.1 and later


===========================================================================
PACKAGING LIST:

EAGLView.h
EAGLView.m

The EAGLView class defines the view object that handles 2D and 3D drawing using OpenGL ES. The object is responsible for updating and displaying the representation of the OpenAL environment and handling user interaction.

MyOpenALSupport.h

MyOpenALSupport.h provides helper functions for various common OpenAL-related tasks (opening files for data read, creating devices and context objects, etc.)

MusicCubePlayback.h
MusicCubePlayback.m

The MusicCubePlayback class defines the audio playback object for the application. The object responds to the OpenAL environment.

MusicCubeAppDelegate.h
MusicCubeAppDelegate.m

The MusicCubeAppDelegate class defines the application delegate object.


================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.1
Updated for iPhone OS 3.1. Use CADisplayLink as the preferred method for controlling animation timing, and fall back to NSTimer when running on a pre 3.1 device where CADisplayLink is not available.


================================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.