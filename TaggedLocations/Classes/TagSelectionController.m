
/*
     File: TagSelectionController.m
 Abstract: The table view controller responsible for displaying all available tags.
 The controller is also given an Event object. Row for tags related to the event display a checkmark.  If the user taps a row, the corresponding tag is added to or removed from the event's tags relationship as appropriate.
 
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */


#import "TagSelectionController.h"

#import "Event.h"
#import "Tag.h"
#import "EditableTableViewCell.h"


@implementation TagSelectionController

@synthesize event, headerView, headerLabel, tagsArray, editableTableViewCell;


- (void)viewDidLoad {
	
	// Configure the table view and controller.
	[super viewDidLoad];	
	self.tableView.allowsSelectionDuringEditing = YES;
	
	// Set up the navigation bar.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.title = @"Tags";
	
	// Set up the header view
	[[NSBundle mainBundle] loadNibNamed:@"TagsHeaderView" owner:self options:nil];
	self.tableView.tableHeaderView = headerView;
	
	NSString *eventName = event.name;
	if (![eventName length] > 0) {
		eventName = @"Unnamed event";
	}
	headerLabel.text = [NSString stringWithFormat:@"Tags for \"%@\" are indicated by a check mark.", eventName];

	// Display all the tags, so fetch then using the event's context.
	// Put the fetched tags into a mutable array.
	NSManagedObjectContext *context = event.managedObjectContext;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag"
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
																   ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	NSMutableArray *mutableArray = [fetchedObjects mutableCopy];
	self.tagsArray = mutableArray;
	[mutableArray release];
	
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	if ([tagsArray count] == 0) {
		// There are no tags, and presumably the user wants to add one.
		// Create and edit one straight away.
		[self setEditing:YES animated:NO];
		[self insertTagAnimated:NO];
	}
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of tags in the array, adding one if editing (for the Add Tag row).
	NSUInteger count = [tagsArray count];
	if (self.editing) {
		count++;
	}
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

	NSUInteger row = indexPath.row;
	
	if (row == [tagsArray count]) {

		// This is the insertion cell.
		static NSString *InsertionCellIdentifier = @"InsertionCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InsertionCellIdentifier];
		if (cell == nil) {		
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InsertionCellIdentifier] autorelease];
			cell.textLabel.text = @"Add Tag";
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		return cell;
	}
	
    
	static NSString *TagCellIdentifier = @"EditableTableViewCell";
	
    EditableTableViewCell *cell = (EditableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TagCellIdentifier];
	
    if (cell == nil) {		
		[[NSBundle mainBundle] loadNibNamed:@"EditableTableViewCell" owner:self options:nil];
		cell = editableTableViewCell;
		self.editableTableViewCell = nil;
    }
    
	// Set the tag on the text field to the row number so it can be identified later if edited.
	cell.textField.tag = row;
	
	Tag *tag = [tagsArray objectAtIndex:row];
	
	// If the tag at this row in the tags array is related to the event, display a checkmark, otherwise remove any checkmark that might have been present.
	cell.textField.text = tag.name;
	if ([event.tags containsObject:tag]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}



#pragma mark -
#pragma mark Editing rows

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// The add row gets an insertion marker, the others a delete marker.
	if (indexPath.row == [tagsArray count]) {
		return UITableViewCellEditingStyleInsert;
	}
    return UITableViewCellEditingStyleDelete;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
	
	// Don't show the Back button while editing.
	[self.navigationItem setHidesBackButton:editing animated:YES];

	
	[self.tableView beginUpdates];
	
    NSUInteger count = [tagsArray count];
    
    NSArray *tagInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:count inSection:0]];
    
	// Add or remove the Add row as appropriate.
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
	if (editing) {
		if (animated) {
			animationStyle = UITableViewRowAnimationFade;
		}
		[self.tableView insertRowsAtIndexPaths:tagInsertIndexPath withRowAnimation:animationStyle];
	}
	else {
        [self.tableView deleteRowsAtIndexPaths:tagInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
	
	// If editing is finished, save the managed object context.
	
	if (!editing) {
		NSManagedObjectContext *context = event.managedObjectContext;
		NSError *error = nil;
		if (![context save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
	}
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

	NSManagedObjectContext *context = event.managedObjectContext;
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
	
		// Delete the tag.
		
		// Ensure the cell is not being edited, otherwise the callback in textFieldShouldEndEditing: may look for a non-existent row.
		EditableTableViewCell *cell = (EditableTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.textField resignFirstResponder];

		
		// Find the tag to delete.
		Tag *tag = [tagsArray objectAtIndex:indexPath.row];

		// Delete the tag from the context.  Because the relationship between Tag and Event is defined in both directions, and the delete rule is nullify, Core Data automatically removes the tag from any relationships in which it is present.
		[context deleteObject:tag];

		// Remove the tag from the tags array and the corresponding row from the table view.
		[tagsArray removeObject:tag];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		// Save the change.
		NSError *error = nil;
		if (![context save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}	
		
    }
	
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		[self insertTagAnimated:YES];
		// Don't save yet as the user must set a name.
	}	
}


- (void)insertTagAnimated:(BOOL)animated {
	
	// Create a new instance of Tag, insert it into the tags array, and add a corresponding new row to the table view.
	
	Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:[event managedObjectContext]];
	
	// Presumably the tag was added for the current event, so relate it to the event.
	[event addTagsObject:tag];
	
	// Add the new tag to the tags array and to the table view.	
	[tagsArray addObject:tag];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[tagsArray count]-1 inSection:0];
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
	if (animated) {
		animationStyle = UITableViewRowAnimationFade;
	}
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animationStyle];
	
	// Start editing the tag's name.
	EditableTableViewCell *cell = (EditableTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell.textField becomeFirstResponder];
}


#pragma mark -
#pragma mark Row selection

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Disable selection of the Add row.
	if (indexPath.row == [tagsArray count]) {
		return nil;
	}
	return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	/*
	 Find the tag at the row index in the tags array, then
	 * If the event currently has this tag, remove the tag;
	 * If the event doesn't have this tag, add the tag.
	
	 (The Add row is not selectable.)
	 */
	Tag *tag = [tagsArray objectAtIndex:indexPath.row];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if ([event.tags containsObject:tag]) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		[event removeTagsObject:tag];
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[event addTagsObject:tag];
	}
	
	// Save the change.
	NSError *error = nil;
	if (![event.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Editing text fields

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

	Tag *tag = [tagsArray objectAtIndex:textField.tag];
	tag.name = textField.text;
	
	return YES;
}	


- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[textField resignFirstResponder];
	return YES;	
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[headerView release];
	[headerLabel release];
	[event release];
	[tagsArray release];
    [super dealloc];
}


@end

