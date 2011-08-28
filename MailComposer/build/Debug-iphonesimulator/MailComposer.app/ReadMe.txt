MailComposer demonstrates how to target older OS versions while building with newly released APIs. This sample also shows how to use the MessageUI framework to create and send email messages from within your application.  

The iPhone OS SDK 3.0 introduces the MFMailComposeViewController class (in the MessageUI framework). This class manages a user interface that allows users to compose and send email messages from within their applications.

MailComposer displays a button labeled "Compose Mail." When users tap "Compose Mail," this application either shows an email composition interface 
or launches the Mail application on the device. 
It shows an email composition interface if MFMailComposeViewController exists and the device is configured for sending emails. It launches the Mail application on the device, otherwise. 


MailComposer runs on earlier and later releases of the iPhone OS and uses new APIs introduced in iPhone SDK 3.0. See below for steps that describe how to target earlier 0S versions while building with newly released APIs.


1. Set your iPhone OS Deployment Target setting to your application's target iPhone OS release
This setting indicates the earliest iPhone OS on which your application can run. We set it to iPhone OS 2.0.


2. Set the Base SDK to the desired iPhone SDK 
This setting indicates what release of the iPhone SDK will be used to build your application. We set it to iPhone SDK 3.0 in order to take advantage of  all the features of the new MessageUI framework. 


3. Make MessageUI a weak framework (set its role to Weak)
An application will fail to launch or proceed if it attempts to load a framework on devices where this framework is absent. 
With weak linking, an application does not fail, but proceeds when a symbol or framework is not present at runtime. All weak-linked symbols are set to NULL on devices without them.

To designate MessageUI as weak-linked, select the target's Link Binary With Libraries build phase, then change MessageUI's role from Required to Weak in the detail view.
 

4. Check for the existence of APIs before calling them
MailComposer will crash if it attempts to use non-existent weak-linked symbols. The showPicker method checks whether MFMailComposeViewController exists (is non-NULL) before using it.


5. Provide a workaround for non-existent APIs
The showPicker method calls the launchMailAppOnDevice method if MFMailComposeViewController does not exist. launchMailAppOnDevice opens the Mail application on devices running earlier releases of the iPhone OS. 


Further Reading
Setting Your Application's Target iPhone OS Release and Setting the Active SDK of the iPhone Development Guide
<http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development> 

Frameworks and Weak Linking
<http://developer.apple.com/DOCUMENTATION/MacOSX/Conceptual/BPFrameworks/Concepts/WeakLinking.html>


Build Requirements:
Mac OS X 10.5.4 or later, Xcode 3.1.3, iPhone OS 3.0


Runtime Requirements:
Mac OS X 10.5.4 or later, iPhone OS 2.0 or later


Using the Sample
Build and run the sample using Xcode 3.1.3 or later. 
Tap the "Compose Mail" button to display an email composition interface if the device is running iPhone OS 3.0 or launch the Mail application, otherwise.



Packaging List
main.m - Main source file for this sample.

MailComposerAppDelegate.h
MailComposerAppDelegate.m
The application's delegate to setup its window and content.


MailComposerViewController.h
MailComposerViewController.m
A view controller for managing the MailComposer view.

MainWindow.xib
The nib file containing the main window.

MailComposerViewController.xib
The view controller's nib file.


Copyright (c) 2009 Apple Inc. All rights reserved.