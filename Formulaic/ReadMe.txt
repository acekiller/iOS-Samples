### Formulaic ###

================================================================================
DESCRIPTION:

Formulaic is a sample iPhone app that illustrates how to effectively use the
iPhone Accessibility API. Using the Accessibility API allows your app to work
correctly with VoiceOver.

The app draws a graph of a formula and allows the user to change certain
constants in the formula, however its main purpose is to illustrate the
iPhone Accessibility API.

The accessibility additions in the app demonstrate the following:
    How to use accessibilityLabel, accessibilityTraits and
        isAccessibilityElement to control the accessibility of the app.
    How to programmatically set values through accessibility to change 
        various accessibility attributes.
    How to use notifications to inform accessibility that an event has
        occurred.
    How to use the accessibility container protocol to transform a single
        UIView that has multiple components into separate accessible elements.
    How to use best practices to craft accessibilityLabels and
        accessibilityHints correctly.

To test the application, build and run Formulaic in iPhone Simulator. Turn on 
Accessibility Inspector, located in Settings > General > Accessibility.
While Accessibility Inspector is active, single-click a user interface element 
to inspect its accessibility information and double-click an element to 
activate it.

Alternatively, sync Formulaic to iPhone and turn on VoiceOver. Touch the 
user interface elements to hear how the accessibility information is presented
to a VoiceOver user.

===========================================================================
RELATED INFORMATION:

Accessibility Programming Guide for iPhone OS, June 2009
http://developer.apple.com/iPhone/library/documentation/UserExperience/Conceptual/iPhoneAccessibility/Accessibility_on_iPhone/Accessibility_on_iPhone.html

Testing the Accessibility of Your iPhone Application, June 2009
http://developer.apple.com/iPhone/library/documentation/UserExperience/Conceptual/iPhoneAccessibility/Testing_Accessibility/Testing_Accessibility.html

iPhone User Guide for iPhone OS 3.0 Software, June 2009
http://manuals.info.apple.com/en_US/iPhone_User_Guide.pdf

================================================================================
BUILD REQUIREMENTS:

Mac OS X v10.5.7, Xcode 3.1, iPhone OS 3.0

================================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.5.7, iPhone OS 3.0

================================================================================
PACKAGING LIST:

AppDelegate.h
AppDelegate.m
UIApplication's delegate class i.e. the central controller of the application.

GraphingView.h
GraphingView.m
The class responsible for drawing the graph, based on the formula.

TabularDataCell.h 
TabularDataCell.m
A UITableViewCell subclass that presents data from the formula in a tabular form.

ViewController.h
ViewController.m
The main view controller of the app.

main.m
The main entry point for the Formulaic application.

Prefix_header.pch
A prefix header.

countdown-on.png
A picture used for a button in the on state.

countdown-off.png
A picture used for a button in the off state.

table.png
A picture used for a button.

Sound.aiff
A sound that is played when a specific button is pressed.

ViewController.xib
An xib file for the main view.

MainWindow.xib
A xib file for the main window.

Formulaic-Info.plist
The Info plist file.

================================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.
