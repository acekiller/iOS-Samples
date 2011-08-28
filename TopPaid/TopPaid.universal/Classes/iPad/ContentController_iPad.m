/*
     File: ContentController_iPad.m 
 Abstract: Content controller used to manage the split view controller and its master popover for the iPad. 
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
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import "ContentController_iPad.h"
#import "DetailViewController.h"
#import "AppListViewController.h"

static NSString *buttonTitle = @"Top Paid Apps";

@implementation ContentController_iPad

@synthesize splitViewController, navigationController, masterViewController, popoverController, detailViewController;

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
    self.masterViewController.contentController = self;
    
    // configure the master popover button:
    //
    // In portrait mode (when the master view is not being displayed by the split view controller)
    // add a bar button item to display the master view in a popover; in landcape mode, remove the button.
    //
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        UIBarButtonItem *popoverMasterViewControllerBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(presentMasterInPopoverFromBarButtonItem:)];
        [self.detailViewController.navBar.topItem setLeftBarButtonItem:popoverMasterViewControllerBarButtonItem animated:YES];
        [popoverMasterViewControllerBarButtonItem release];
    }
    else
    {
        [self.detailViewController.navBar.topItem setLeftBarButtonItem:nil animated:YES];
    }
}

- (IBAction)presentMasterInPopoverFromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (popoverController == nil)
    {
        Class cls = NSClassFromString(@"UIPopoverController");
        if (cls != nil)
        {
            UIPopoverController *aPopoverController =
                [[cls alloc] initWithContentViewController:self.masterViewController];
            self.popoverController = aPopoverController;
            
            [aPopoverController release];
            
            [popoverController presentPopoverFromBarButtonItem:barButtonItem
                                      permittedArrowDirections:UIPopoverArrowDirectionUp
                                                      animated:YES];
        }
    }
}

- (void)dealloc
{
    [splitViewController release];
    [masterViewController release];
    [popoverController release];
    [navigationController release];
    
    [detailViewController release];
    
    [super dealloc];
}

// when setting the detail item, update the view and dismiss the popover controller if it's showing
//
- (void)setDetailItem:(AppRecord *)newDetailItem
{
    if (detailItem != newDetailItem)
    {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        self.detailViewController.appIcon.image = detailItem.appIcon;
        self.detailViewController.appName.text = detailItem.appName;
        self.detailViewController.appArtist.text = detailItem.artist;
        self.detailViewController.appPrice.text = detailItem.price;
        self.detailViewController.appRights.text = detailItem.rights;
        self.detailViewController.appReleaseDate.text = detailItem.releaseDate;
        self.detailViewController.appSummary.text = detailItem.summary;
        
        self.detailViewController.appURLButton.hidden = NO;
        self.detailViewController.appURL = [NSURL URLWithString:detailItem.appURLString];

        [self.detailViewController.appSummary scrollRectToVisible:CGRectMake(0.0, 0.0, 1.0, 1.0) animated:YES];
        [self.detailViewController.appSummary flashScrollIndicators];
    }
    
    if (self.popoverController != nil)
    {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}


#pragma mark -
#pragma mark Split view support

- (UIView *)view
{
    return self.splitViewController.view;
}

- (void)splitViewController: (UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController
                                                              withBarButtonItem:(UIBarButtonItem *)barButtonItem
                                                           forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = buttonTitle;
    [self.detailViewController.navBar.topItem setLeftBarButtonItem:barButtonItem animated:NO];
    self.popoverController = pc;
}


// called when the view is shown again in the split view, invalidating the button and popover controller
//
- (void)splitViewController: (UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController
                                                        invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.detailViewController.navBar.topItem setLeftBarButtonItem:nil animated:NO];
    self.popoverController = nil;
}

@end
