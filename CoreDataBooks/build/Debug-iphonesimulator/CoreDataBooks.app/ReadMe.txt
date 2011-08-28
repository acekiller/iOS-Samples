
CoreDataBooks
=============

This sample illustrates a number of aspects of working with the Core Data framework with an iPhone application:

* Use of an instance of NSFetchedResultsController object to manage a collection of objects to be displayed in a table view.
* Use of a second managed object context to isolate changes during an add operation.
* Undo and redo. 
* Database initialization.

This sample assumes some familiarity with the Core Data framework, and with UIKit view controllers and table views. As a minimum, you should have worked through the "Core Data Tutorial for iPhone OS" tutorial.


Build and runtime Requirements
------------------------------
Build Requirements
Mac OS X 10.5.7, Xcode 3.1, iPhone OS 3.0.

Runtime Requirements
Mac OS X 10.5.7, iPhone OS 3.0.


Running the Sample
------------------
The sample presents a simple master-detail interface. The master is a list of book titles. Selecting a title navigates to the detail view for that book. The master has a navigation bar (at the top) with a "+" button on the right for creating a new book. This creates the new book and then navigates immediately to the detail view for that book. There is also an "Edit" button. This displays a "-" button next to each book. Touching the minus button shows a "Delete" button which will delete the book from the list. 

The detail view displays three fields: title, copyright date, and author. The user can navigate back to the main list by touching the "Books" button in the navigation bar. If the user taps Edit, they can modify individual fields. Until they tap Save, they can also undo up to three previous changes.



Packaging List
--------------

CoreDataBooksAppDelegate.{h,m}
Configures the Core Data stack and the first view controllers.

RootViewController.{h,m}
Manages a table view for listing all books. Provides controls for adding and removing books.

DetailViewController.{h,m}
Manages a detail display for display fields of a single Book. 

AddViewController.{h,m}
Subclass of DetailViewController with functionality for managing new Book objects.

EditingViewController.{h,m}
View for editing a field of data, text or date.

Book.{h,m}
A simple managed object class to represent a book.

CoreDataBooks.sqlite
A pre-populated database file that is copied into the appropriate location when the application is first launched.

CoreDataBooks.xcdatamodel
The Core Data managed object model for the application.



Changes from Previous Versions
------------------------------

Version 1.1
Updated to use NSFetchedResultsController's controllerWillChangeContent: delegate method, and an update to UITableView's change-handling, to allow for more fluid updates.
Corrected a memory leak in EditingViewController.

Version 1.0
First release.
===========================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.
