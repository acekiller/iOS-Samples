PageControl

This application demonstrates use of UIScrollView's paging functionality to use horizontal scrolling as a mechanism for navigating between different pages of content. Each page is managed by its own view controller which is loaded only when it is needed. A UIPageControl is displayed at the bottom of the window as an alternative interface for moving between pages.

Build Requirements
iPhone SDK 3.0 and later.

Runtime Requirements
iPhone OS 3.0 and later.

Packaging List
main.m
Launches the application and specifies the class name for the application delegate.

AppDelegate
Application and scroll view delegate. This object manages the view controllers which are the pages in the scroll view.

MyViewController
A controller for a single page of content. For this application, pages simply display text on a black background.

Changes from Previous Versions
1.2 Fixed issue where scrolling by dragging the UIScrollView did not update the UIPageControl.
1.1 Added a check to eliminate flicker of the UIPageControl when it is used to change pages.
1.0 Initial version.

Copyright (C) 2010 Apple Inc. All rights reserved.
