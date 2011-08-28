QuartzDemo

QuartzDemo is an iPhone OS application that demonstrates many of the Quartz2D APIs made available by the CoreGraphics framework. Quartz2D forms the foundation of all drawing on iPhone OS and provides facilities for drawing lines, polygons, curves, images, gradients, PDF and many other graphical facilities.

In this sample stroked paths are typically drawn in white. Lines and other graphical elements drawn in red are meant to show some aspect of how the element was constructed, such as the path used to construct the object, or a clipping rectangle used to limit drawing to a particular area and are not part of the actual demonstrated result. Filled paths and areas use colors other than red, with a red fill used to similar effect as with stroked paths.

Build Requirements

iPhone SDK 3.1.2

Runtime Requirements

iPhone OS 3.0

Source File List

Classes/AppDelegate.h/m:
The application delegate. It creates and configures the view & navigation controllers for the application.

Classes/MainViewController.h/m:
Implements the main interface to the demo application, allowing the user to display which of Quartz's drawing facilities to demonstrate.

Classes/QuartzView.h/m:
A UIView subclass that is the super class of the other demonstration views in this sample.

Classes/QuartzViewController.h/m:
A UIViewController subclass that manages a single QuartzView and allows the user to zoom and pan around the hosted QuartzView.

Classes/QuartzBlendingViewController.h/m:
A QuartzViewController subclass that manages a QuartzBlendingView and a UI to allow for the selection of foreground color, background color and blending mode to demonstrate.

Classes/QuartzPolyViewController.h/m:
A QuartzViewController subclass that manages a QuartzPolygonView and a UI to allow for the selection of the stroke and fill mode to demonstrate.

Classes/QuartzGradientController.h/m:
A QuartzViewController subclass that manages a QuartzGradientView and a UI to allow for the selection of gradient type and if the gradient extends past its start or end point.

Classes/QuartzLineViewController.h/m:
A QuartzViewController subclass that manages a QuartzCapJoinWidthView and a UI to allow for the selection of the line cap, line join and line width to demonstrate.

Classes/QuartzDashViewController.h/m:
A QuartzViewController subclass that manages a QuartzDashView and a UI to allow for the selection of the line dash pattern and phase.

Quartz/QuartzLines.h/m:
Demonstrates Quartz line drawing facilities (QuartzLineView), including dash patterns (QuartzDashView), stroke width, line cap and line join (QuartzCapJoinWidthView).

Quartz/QuartzPolygons.h/m:
Demonstrates using Quartz to stroke & fill rectangles (QuartzRectView) and polygons (QuartzPolygonView).

Quartz/QuartzCurves.h/m:
Demonstrates using Quartz to draw ellipses & arcs (QuartzEllipseArcView) and bezier & quadratic curves (QuartzBezierView).

Quartz/QuartzImages.h/m:
Demonstrates using Quartz for drawing images (QuartzImageView), PDF files (QuartzPDFView), and text (QuartzTextView).

Quartz/QuartzRendering.h/.m:
Demonstrates using Quartz for drawing gradients (QuartzGradientView) and patterns (QuartzPatternView).

Quartz/QuartzBlending.h/.m:
Demonstrates Quartz Blend modes (QuartzBlendingView).

Quartz/QuartzClipping.h/m:
Demonstrates using Quartz for clipping (QuartzClippingView) and masking (QuartzMaskingView).

main.m:
The application's main entry point.

Changes From Previous Versions

2.3: Added masking and clipping demos in QuartzClipping.h/m. Made some of the demos dynamic. Reorganized some of the class names.
2.2: Changed the demo classes to be subclasses of the QuartzView class. Improved QuartzViewController to allow the user to zoom and pan the demo views, and to improve its low memory handling. Added a Blending demo.
2.1: Fixed a memory management error in the MainViewController.
2.0: First public release.
1.3: Now uses nibs. Moved gradient drawing into QuartzRendering.h/m and added a pattern drawing demo.
1.2: Updated for Beta 5 for changes to UITableViewDelegate.
1.1: Updated for Beta 4 for changes to UINavigationBarController and UINavigationBar.

Copyright (C) 2008-2010 Apple Inc. All rights reserved.
