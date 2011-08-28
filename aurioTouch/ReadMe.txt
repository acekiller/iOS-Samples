
aurioTouch

===========================================================================
DESCRIPTION:

aurioTouch demonstrates use of the remote i/o audio unit for handling audio input and output. The application can display the input audio in one of the forms, a regular time domain waveform, a frequency domain waveform (computed by performing a fast fourier transform on the incoming signal), and a sonogram view (a view displaying the frequency content of a signal over time, with the color signaling relative power, the y axis being frequency and the x as time). Tap the sono button to switch to a sonogram view, tap anywhere on the screen to return to the oscilloscope. Tap the FFT button to perform and display the input data after an FFT transform. Pinch in the oscilloscope view to expand and contract the scale for the x axis.

The code in auriouTouch uses the remote i/o audio unit (AURemoteIO) for input and output of audio, and OpenGL for display of the input waveform. The application also uses Audio Session Services to manage route changes (as described in Core Audio Overview).

This application shows how to:

	* Set up the remote i/o audio unit for input and output.
	* Use OpenGL for graphical display of audio waveforms.
	* Use touch events such as tapping and pinching for user interaction
	* Use Audio Session Services to handle route changes and reconfigure the unit in response.
	* Use Audio Session Services to set an audio session category for concurrent input and output.
	* Use Audio Session Services to play simple alert sounds.
	
aurioTouch does not demonstrate how to handle interruptions. 


===========================================================================
RELATED INFORMATION:

Core Audio Overview, June 2008


===========================================================================
SPECIAL CONSIDERATIONS:

aurioTouch requires audio input, and so is not appropriate for the first generation iPod touch.


===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.5.3, Xcode 3.1, iPhone OS 2.0, iPhone SDK for iPhone OS 2.0 and later


===========================================================================
RUNTIME REQUIREMENTS:

Simulator: Mac OS X v10.5.3, iPhone SDK Beta 6
iPhone: iPhone OS 2.0


===========================================================================
PACKAGING LIST:

EAGLView.h
EAGLView.m

This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.

aurio_helper.cpp
aurio_helper.h

Helper functions for manipulating the remote i/o audio unit, responsible for setting up the remote i/o.

aurioTouchAppDelegate.h
aurioTouchAppDelegate.mm


The application delegate for the aurioTouch app, responsible for handling touch events and drawing.

FFTBufferManager.cpp
FFTBufferManager.h

This class manages buffering and computation for FFT analysis on input audio data. The methods provided are used to grab the audio, buffer it, and perform the FFT when sufficient data is available.

rad2fft.h
rad2fft.c

Provides a set of methods for radix 2 integer FFT operations.

SpectrumAnalysis.cpp
SpectrumAnalysis.h

This class provides a simple spectral analysis tool.

CAMath.h

CAMath is a helper class for various math functions.

CADebugMacros.h
CADebugMacros.cpp

A helper class for printing debug messages.

CAXException.h
CAXException.cpp

A helper class for exception handling.

CAStreamBasicDescription.cpp
CAStreamBasicDescription.h

A helper class for AudioStreamBasicDescription handling and manipulation.

================================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.
