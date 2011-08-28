### Locations ###

===========================================================================
DESCRIPTION:

This sample illustrates how to manipulate attributes and relationships in an iPhone application.

The application extends the the completed project from the Core Data Tutorial for iPhone OS. The first screen displays a table view of events, which encapsulate a time stamp, a geographical location expressed in latitude and longitude, and a name for the event. The user can add, remove, and edit events using the first screen.

Events have a to-many relationship to tags (which have an inverse to-many relationship to events). Tags have a name which describes a feature of an event. Tags are displayed in a second table view; when a tag is related to the selected event, a check mark is displayed in the corresponding row.



===========================================================================
BUILD REQUIREMENTS:

Xcode 3.1 or later, Mac OS X v10.5.7 or later, iPhone OS 3.0

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.5.7 or later, iPhone OS 3.0

===========================================================================
PACKAGING LIST:

View Controllers
----------------

RootViewController.{h,m}
The table view controller responsible for displaying the list of events, supporting additional functionality:
 * Addition of new new events
 * Deletion of existing events using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method
 * Editing an event's name


TagSelectionController.{h,m}
The table view controller responsible for displaying and editing tags.
The rows show a check mark if the selected event is related to the corresponding tag. 


Model
-----

TaggedLocations.xcdatamodel
The Core Data managed object model for the application.

Event.{h,m}
A Core Data managed object class to represent an event containing geographical coordinates and a time stamp.

Tag.{h,m}
A Core Data managed object class to represent a tag.


Table View Cells
----------------

EventTableViewCell.{h,m}
EventTableViewCell.xib
Table view cell to display information about an event.
The File's Owner is the RootViewController table view controller which acts as:
* The name text field's delegate to respond to editing operations
* The target of the tag button to initiate tag editing


EditableTableViewCell.{h,m}
EditableTableViewCell.xib
Table view cell to present an editable text field.
The File's Owner is the TagSelectionController table view controller which acts as the text field's delegate to respond to editing operations.


Application configuration
-------------------------

LocationsAppDelegate.{h,m}
Configures the Core Data stack and the first view controller.

MainWindow.xib
Loaded automatically by the application. Creates the application's delegate and window.


===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.1
- Added identifier to table view cell in EditableTableViewCell.xib.

Version 1.0
- First version.

===========================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.
