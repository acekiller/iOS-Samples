/*
     File: Level1ViewController.m
 Abstract: The application's level 1 view controller.
  Version: 1.2
 
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

#import "AppDelegate.h"
#import "Level1ViewController.h"
#import "Level2ViewController.h"

@implementation Level1ViewController

@synthesize listContent, level2ViewController, myTableView;

- (void)dealloc
{
    [myTableView release];
	[listContent release];
	[level2ViewController release];
	[super dealloc];
}

- (void)awakeFromNib
{	
	self.title = @"Level 1";
}


#pragma mark UIViewController delegates

- (void)viewWillAppear:(BOOL)animated
{
	[myTableView reloadData];	// populate our table's data
	
	NSIndexPath *tableSelection = [myTableView indexPathForSelectedRow];
	[myTableView deselectRowAtIndexPath:tableSelection animated:NO];
}


#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [listContent count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// save off this level's selection to our AppDelegate
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:indexPath.row]];
	[appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	[appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:-1]];
	
	// provide the 2nd level its content
	level2ViewController.listContent = [[listContent objectAtIndex:indexPath.row] objectForKey:kChildrenKey];
	
	// move to the 2nd level
	[[self navigationController] pushViewController:level2ViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	// get the view controller's info dictionary based on the indexPath's row
	NSDictionary* item = [listContent objectAtIndex:indexPath.row];
	cell.textLabel.text = [item objectForKey:kItemTitleKey];
	
	return cell;
}

// User was last at level 2 or deeper
//
// note: this is a part of a chain reaction down each level (2nd, 3rd, etc.)
// so that each level restores itself and pushes further down until there's no further stored selections.
//
- (void)restoreLevel:(NSArray*)items withSelectionArray:(NSArray *)selectionArray
{
	// user was last at level 2 or deeper
	//
	self.listContent = items;	// remember our content here at level 1 in case user navigates back to this level
	
	// move in level 2 and restore its content (not animated since the user should not see the restore process)
	[[self navigationController] pushViewController:level2ViewController animated:NO];
	
	// get the level 2 content
	NSInteger itemIdx = [[selectionArray objectAtIndex:0] integerValue];
	NSArray *itemContent = [[items objectAtIndex:itemIdx] objectForKey:kChildrenKey];
	
	// narrow down the selection array for level 2
	NSArray *newSelectionArray = [selectionArray subarrayWithRange:NSMakeRange(1, [selectionArray count]-1)];
	
	// restore that level
	[level2ViewController restoreLevel:itemContent withSelectionArray:newSelectionArray];
}

- (void)viewDidAppear:(BOOL)animated
{
	// we have moved to level 1, remove it's stored selection
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:-1]];
}

@end

