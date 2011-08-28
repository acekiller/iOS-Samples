DateCell

Demonstrates formatted display of date objects in table cells and use of UIDatePicker to edit those values.

Using a grouped style UITableViewController, the sample has two UITableViewCells to draw the primary title and NSDate values.
This is accomplished using the built-in cell type "UITableViewCellStyleValue1" which supports left and right text.
As a delegate to this table, the sample uses the method "didSelectRowAtIndexPath" to open the UIDatePicker control.
UIViewAnimation is used for sliding the picker up on-screen and down off-screen.
The action method of the UIDatePicker will directly set the NSDate property of the custom table cell.
The Done button is a UIBarButton item set as the "rightBarButtonItem" of the navigation controller and it set only when the picker is open.
In addition, this sample shows how to use NSDateFormatter class to achieve the custom cell's date-formatted appearance.


Build Requirements
Mac OS X 10.5.6 or later, iPhone OS 3.0 SDK.


Runtime Requirements
Mac OS X 10.5.6 or later, iPhone OS 3.0 SDK.


Using the Sample
Launch the DateCell project using Xcode.

To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting.
When launched launched, touch the Start Date cell to change its value.  A UIDatePicker view will slide onto the screen from the bottom.
As you pick the month, day, year components on the picker, the cell's date changes on-the-fly.

You can click the Done button to finish the edit which will dismiss the picker as it slides down off screen.
The targeted cell will become deselected.   In addition while the picker is open, you can also freely tap between both Start and End dates to change their values.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application's delegate to setup its window and content.
MyTableViewController.h/.m - The main UITableViewController controlling the table and date picker.


Changes from Previous Versions
1.0 - First release.


Copyright (C) 2009 Apple Inc. All rights reserved.