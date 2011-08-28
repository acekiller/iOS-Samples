
/*
     File: ToolbarSearchViewController.m
 Abstract: A view controller that manages a search bar and a recent searches controller.
 The view controller creates a search bar to place in a tool bar. When the user commences a search, a recent searches controller is displayed in a popover.
 
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
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "ToolbarSearchViewController.h"
#import "RecentSearchesController.h"


@interface ToolbarSearchViewController()
- (void)finishSearchWithString:(NSString *)searchString;
@end


@implementation ToolbarSearchViewController


@synthesize toolbar, searchBar, recentSearchesController, recentSearchesPopoverController, progressLabel;


#pragma mark -
#pragma mark Create and manage the search results controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create and configure a search bar.
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 400.0, 0.0)];
    searchBar.delegate = self;
    
    
    // Create a bar button item using the search bar as its view.
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    // Create a space item and set it and the search bar as the items for the toolbar.
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    toolbar.items = [NSArray arrayWithObjects:spaceItem, searchItem, nil];
    [spaceItem release];
    [searchItem release];    
    
    // Create and configure the recent searches controller.
    RecentSearchesController *aRecentsController = [[RecentSearchesController alloc] initWithStyle:UITableViewStylePlain];
    self.recentSearchesController = aRecentsController;
    recentSearchesController.delegate = self;
    
    // Create a navigation controller to contain the recent searches controller, and create the popover controller to contain the navigation controller.
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:recentSearchesController];
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    self.recentSearchesPopoverController = popover;
    recentSearchesPopoverController.delegate = self;
    
    // Ensure the popover is not dismissed if the user taps in the search bar.
    popover.passthroughViews = [NSArray arrayWithObject:searchBar];

    [navigationController release];
    [aRecentsController release];
    [popover release];
}


#pragma mark -
#pragma mark Search results controller delegate method

- (void)recentSearchesController:(RecentSearchesController *)controller didSelectString:(NSString *)searchString {
    
    /*
     The user selected a row in the recent searches list.
     Set the text in the search bar to the search string, and conduct the search.
     */
    searchBar.text = searchString;
    [self finishSearchWithString:searchString];
}


#pragma mark -
#pragma mark Search bar delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    
    // Display the search results controller popover.
    [recentSearchesPopoverController presentPopoverFromRect:[searchBar bounds] inView:searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    
    // If the user finishes editing text in the search bar by, for example tapping away rather than selecting from the recents list, then just dismiss the popover.
    [recentSearchesPopoverController dismissPopoverAnimated:YES];
    [aSearchBar resignFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // When the search string changes, filter the recents list accordingly.
    [recentSearchesController filterResultsUsingString:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    
    // When the search button is tapped, add the search term to recents and conduct the search.
    NSString *searchString = [searchBar text];
    [recentSearchesController addToRecentSearches:searchString];
    [self finishSearchWithString:searchString];
}


- (void)finishSearchWithString:(NSString *)searchString {
    
    // Conduct the search. In this case, simply report the search term used.
    [recentSearchesPopoverController dismissPopoverAnimated:YES];
    progressLabel.text = [NSString stringWithFormat:@"Performed a search using \"%@\".", searchString];
    [searchBar resignFirstResponder];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    // Remove focus from the search bar without committing the search.
    progressLabel.text = @"Canceled a search.";
    [searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark View lifecycle

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    self.recentSearchesController = nil;
    self.recentSearchesPopoverController = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [searchBar release];
    [toolbar release];
    [recentSearchesController release];
    [recentSearchesPopoverController release];
    [super dealloc];
}

@end
