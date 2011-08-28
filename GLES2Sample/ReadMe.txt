GLES2Sample

================================================================================
DESCRIPTION:

iPhone 3GS supports both OpenGL ES 1.1 and 2.0. This sample demonstrates how to create an OpenGL ES 1.1 and 2.0 compatible project. When running on iPod Touch, 1st generation iPhone, and iPhone 3G, the sample draws using OpenGL ES 1.1; when running on iPhone 3GS, the sample draws using OpenGL ES 2.0.

================================================================================
BUILD REQUIREMENTS:

Mac OS X 10.5.3, Xcode 3.1, iPhone SDK 3.0 and later

================================================================================
RUNTIME REQUIREMENTS:

Mac OS X 10.5.3, iPhone OS 3.0 and later

================================================================================
PACKAGING LIST:

ESRenderer.h
A protocol that defines the functions the ES1Renderer and ES2Renderer classes must implement.

ES1Renderer.h
ES1Renderer.m
The ES1Renderer class creates an OpenGL ES 1.1 context and draws using OpenGL ES 1.1 functions.

ES2Renderer.h
ES2Renderer.m
The ES2Renderer class creates an OpenGL ES 2.0 context and draws using OpenGL ES 2.0 shaders.

Shaders.h
Shaders.m
Include shader utilities for compiling, linking and validating shaders. It is important to check the result status.

EAGLView.h
EAGLView.m
The EAGLView class is a UIView subclass that renders OpenGL scene. The sample first tries to allocate an OpenGL ES 2.0 context, if fails it falls back to create an OpenGL ES 1.1 context.

GLES2SampleAppDelegate.h
GLES2SampleAppDelegate.m
The GLES2SampleAppDelegate class is the app delegate that ties everything together.

matrix.h
matrix.m
Include wrapper functions to create scaling, rotation and translation matrices, orthographic and perspective projection matrices. Also include a function to compute 4x4 matrix multiplication.

template.vsh
A vertex shader that implements the drawing in the OpenGL ES project template.

template.fsh
A fragment shader that implements the drawing in the OpenGL ES project template.

================================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.