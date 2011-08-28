/*
     File: AppDelegate.m
 Abstract: The application delegate class used for adding our navigation controller.
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

NSString *kItemTitleKey		= @"itemTitle";		// dictionary key for obtaining the item's title to display in each cell
NSString *kChildrenKey		= @"itemChildren";	// dictionary key for obtaining the item's children
NSString *kCellIdentifier	= @"MyIdentifier";	// the table view's cell identifier

NSString *kRestoreLocationKey = @"RestoreLocation";	// preference key to obtain our restore location


@implementation AppDelegate

@synthesize window, outlineData, navigationController, savedLocation;

- (id)init
{
	self = [super init];
	if (self)
	{
		// load the drill-down list content from the plist filem
		// this plist contains the outline mapping each level of the list hierarchy
		//
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"outline.plist"];
		outlineData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
	}
	return self;
}

- (void)dealloc
{
	[navigationController release];  
	[window release];
	[outlineData release];
	[savedLocation release];
	
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// fetch the top level items in our outline (level 1)
	NSArray *topLevel1Content = [outlineData objectForKey:kChildrenKey];
	
	// give the top view controller its content
	((Level1ViewController*)navigationController.topViewController).listContent = topLevel1Content;
		
	// load the stored preference of the user's last location from a previous launch
	NSMutableArray *tempMutableCopy = [[[NSUserDefaults standardUserDefaults] objectForKey:kRestoreLocationKey] mutableCopy];
	self.savedLocation = tempMutableCopy;
	[tempMutableCopy release];
	if (savedLocation == nil)
	{
		// user has not launched this app nor navigated to a particular level yet, start at level 1, with no selection
		savedLocation = [[NSMutableArray arrayWithObjects:
						  [NSNumber numberWithInteger:-1],	// item selection at 1st level (-1 = no selection)
						  [NSNumber numberWithInteger:-1],	// .. 2nd level
						  [NSNumber numberWithInteger:-1],	// .. 3rd level
						  nil] retain];
	}
	else
	{
		NSInteger selection = [[savedLocation objectAtIndex:0] integerValue];	// read the saved selection at level 1
		if (selection != -1)
		{
			// user was last at level 2 or deeper
			//
			// note: this starts a chain reaction down each level (2nd, 3rd, etc.)
			// so that each level restores itself and pushes further down until there's no further stored selections.
			//
			[(Level1ViewController*)navigationController.topViewController restoreLevel:topLevel1Content withSelectionArray:savedLocation];
		}
		else
		{
			// no saved selection, so user was at level 1 the last time
		}
	}
	
	// add the navigation controller's view to the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	// register our preference selection data to be archived
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:savedLocation forKey:kRestoreLocationKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// save the drill-down hierarchy of selections to preferences
	[[NSUserDefaults standardUserDefaults] setObject:savedLocation forKey:kRestoreLocationKey];
}

@end
