/*
     File: RootViewController.m
 Abstract: Top-level view controller class implementation
  Version: 1.0
 
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

#import "RootViewController.h"
#import "DetailViewController.h"

/* key names for values in mountain dictionary entries */
#define kMountainNameString				@"name"
#define kMountainHeightString			@"height"
#define kMountainClimbedDateString		@"climbedDate"

/* Class extension for "private" methods */
@interface RootViewController ()
- (void)loadMountainsWithBundle:(NSBundle *)bundle;
@end

/* A C-function used as the comparator for our call to 
   NSArray:sortedArrayUsingFunction below.  Uses NSString:localizedCompare */
NSInteger mountainSort(id m1, id m2, void *context) {
	/* A private comparator fcn to sort two mountains.  To do so,
	 we do a localized compare of mountain names, using 
	 NSString:localizedCompare. */
	NSString *m1Name = @"";
	NSString *m2Name = @"";
	if (m1 != nil && [m1 isKindOfClass:[NSDictionary class]] &&
		m2 != nil && [m2 isKindOfClass:[NSDictionary class]]) {
		m1Name = [(NSDictionary *) m1 objectForKey:kMountainNameString];
		m2Name = [(NSDictionary *) m2 objectForKey:kMountainNameString];
	}
	return [m1Name localizedCompare:m2Name]; 
}


@implementation RootViewController


- (void)dealloc {
	[detailViewController release];
	[mountains release];
	[super dealloc];
}


- (void)sortMountains {
	NSArray *sortedArray; 
	/* Sort mountains using the mountainSort comparator */
	sortedArray = [mountains sortedArrayUsingFunction:mountainSort context:NULL];	
	/* re-set mountains to be the new sorted array */
	[mountains release];
	mountains = [[NSArray alloc] initWithArray:sortedArray];	
}


#pragma mark --UIViewController--


- (void)viewDidLoad {
	/* Set the title property that will be used by the navigation controller
	   as the UI navbar title for this view.  Naturally, this is localized. */
	self.title = NSLocalizedString(@"rootViewNavTitle", 
								   @"Title used for the Navigation Controller for the root view");	
	/* Create and load our mountain data array, which will access the correct
	   localized Mountains.plist from the application bundle. */
	[self loadMountainsWithBundle:[NSBundle mainBundle]];
}


#pragma mark --UITableViewController--


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [mountains count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /* Use a re-usable TableViewCell, or create if we don't have one yet */
	static NSString *kCellIdentifier = @"MyCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	/* Get the text to display in the tableview cell.  We've already loaded
	   the localized mountain name from the bundle data using loadMountainsWithBundle */
	NSDictionary *mountainDictionary = [mountains objectAtIndex:[indexPath row]];
	cell.text = [mountainDictionary objectForKey:kMountainNameString];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/* Create the detail view controller if we haven't already, and pass along 
	   the currently selected item information */
	if (detailViewController == nil) {
		detailViewController = [[DetailViewController alloc] 
								initWithNibName:@"DetailViewController" bundle:nil];
		/* Set the title property that will be used by the navigation controller
		 as the UI navbar title for this view.  Naturally, this is localized. */
		detailViewController.title = NSLocalizedString(@"detailViewNavTitle", 
									   @"Title used for the Navigation Controller for the detail view");		
	}	    
    /* Push the detail view controller onto the navigation controller stack.
	   Note that we do not release the detailViewController afterwards, even 
	   though the navigation controller will have retained it, because we will
	   be using the same detailViewController instance each time we need to
	   show a detail view. */
    [[self navigationController] pushViewController:detailViewController animated:YES];
	/* Update detail view's text label contents given the current selection.
	   Do this after pushing the controller to the NavigationController, to ensure
	   that the nib for the DetailViewController has been unarchived already. */
	NSDictionary *mountainDictionary = [mountains objectAtIndex:[indexPath row]];
    [detailViewController updateLabelWithMountainName:[mountainDictionary objectForKey:kMountainNameString]  
											   height:[mountainDictionary objectForKey:kMountainHeightString]  
										  climbedDate:[mountainDictionary objectForKey:kMountainClimbedDateString]];
}


- (void)viewWillAppear:(BOOL)animated {
	/* The view is about to re-appear, make sure we remove the current selection 
	   in our table view. */
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}


#pragma mark --RootViewController (private methods)--


- (void)loadMountainsWithBundle:(NSBundle *)bundle {
	if (bundle != nil) {
		/* Read the mountain data in from the app bundle, relying on the system to
		 properly give us the correct, localized version of the data file
		 (Mountains.plist) based on current user language setting.
		 Note: While this sample uses plists for the localized data source,
		 there are many other options (sqlite db, flat file, etc) that can
		 all be localized as long as they are available in properly set-up
		 localized project resource folders. */
		NSString *path = [bundle pathForResource:@"Mountains" ofType:@"plist"];
		NSArray *mountainList = (path != nil ? [NSArray arrayWithContentsOfFile:path] : nil);
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:
								 (mountainList != nil ? [mountainList count] : 0)];
		for (NSDictionary *mountainDict in mountainList) {
			/* add the given mountain dictionary to our array */
			[array addObject:mountainDict];
		}
		/* Copy into our non-mutable array */
		mountains = [[NSArray alloc] initWithArray:array];
	}
}


@end
