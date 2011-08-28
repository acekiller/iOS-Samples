/*
     File: MyViewController.m
 Abstract: The main view controller of this app.
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
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */

#import "MyViewController.h"
#import "HoverView.h"

NSString *Show_HoverView = @"SHOW";

@implementation MyViewController

@synthesize hoverView, leftButton, rightButton;

- (void)viewDidLoad
{
	// determine the size of HoverView
	CGRect frame = hoverView.frame;
	frame.origin.x = round((self.view.frame.size.width - frame.size.width) / 2.0);
	frame.origin.y = self.view.frame.size.height - 100;
	hoverView.frame = frame;
	
	[self.view addSubview:hoverView];
	
	// called by MainView, when the user touches once on the background image
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewNotif:) name:Show_HoverView object:nil];
}


- (void)showHoverView:(BOOL)show
{
	// reset the timer
	[myTimer invalidate];
	[myTimer release];
	myTimer = nil;
	
	// fade animate the view out of view by affecting its alpha
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.40];

	if (show)
	{
		// as we start the fade effect, start the timeout timer for automatically hiding HoverView
		hoverView.alpha = 1.0;
		myTimer = [[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO] retain];
		[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
	}
	else
	{
		hoverView.alpha = 0.0;
	}
	
	[UIView commitAnimations];
}

- (void)timerFired:(NSTimer *)timer
{
	// time has passed, hide the HoverView
	[self showHoverView: NO];
}

- (void)showViewNotif:(NSNotification *)aNotification
{
	// start over - reset the timer
	[myTimer invalidate];
	[myTimer release];
	myTimer = nil;
	
	[self showHoverView:(hoverView.alpha != 1.0)];
}

- (void)dealloc
{
	[leftButton release];
	[rightButton release];
	[hoverView release];
	[myTimer release];
	
	// no longer interested in Show_HoverView notifs
	[[NSNotificationCenter defaultCenter] removeObserver:self name:Show_HoverView object:nil];
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// invoke super's implementation to do the Right Thing, but also release the input controller since we can do that	
	// In practice this is unlikely to be used in this application, and it would be of little benefit,
	// but the principle is the important thing
	//
	[super didReceiveMemoryWarning];
}

- (IBAction)leftAction:(id)sender
{
	// user touched the left button in HoverView
	[self showHoverView:NO];
}

- (IBAction)rightAction:(id)sender
{
	// user touched the right button in HoverView
	[self showHoverView:NO];
}

@end

