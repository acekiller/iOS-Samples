/*
     File: DetailViewController.m 
 Abstract: Detail view showing more extended information running on the iPad. 
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

#import "DetailViewController.h"

@implementation DetailViewController

@synthesize navBar, appIcon, appName, appArtist, appPrice, appRights, appReleaseDate, appSummary, appURLButton, appURL;


- (void)dealloc
{
    [navBar release];
    [appIcon release];
    [appName release];
    [appArtist release];
    [appPrice release];
    [appRights release];
    [appReleaseDate release];
    [appSummary release];
    [appURL release];
    [appURLButton release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:197.0/255.0
                                                green:204.0/255.0
                                                 blue:211.0/255.0
                                                alpha:1.0];
    
    // make the scroll view background a little lighter
    self.appSummary.backgroundColor = [UIColor colorWithRed:(197.0/255.0)*20
                                                green:(204.0/255.0)*20
                                                 blue:(211.0/255.0)*20
                                                alpha:0.3];
}

- (void)viewDidUnload
{
    // release any retained subviews of the main view
    self.navBar = nil;
    self.appIcon = nil;
    self.appName = nil;
    self.appArtist = nil;
    self.appPrice = nil;
    self.appRights = nil;
    self.appReleaseDate = nil;
    self.appSummary = nil;
    self.appURLButton = nil;
    self.appURL = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in
// both portrait and landscape.
//
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // no popouts for lanscape orientation (use the MasterViewController's table)
    //
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [self.navBar.topItem setLeftBarButtonItem:nil animated:NO];
    }
}

- (IBAction)appLinkAction:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.appURL];
}

@end
