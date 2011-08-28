/*
     File: MyViewController.m
 Abstract: The main table view controller of this app.
  Version: 1.3
 
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

#import "MyViewController.h"
#import "AppDelegate.h"

@implementation MyViewController

@synthesize instructionsView, flipButton, doneButton;

- (void)dealloc
{
	[instructionsView release];
	[flipButton release];
	[doneButton release];
	
	// unregister for this notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:nil]; 

	[super dealloc];
}

- (void)viewDidLoad
{
	// watch when the app has finished launching so we can update our preference settings and apply them to the UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSettings:) 
										name:UIApplicationDidFinishLaunchingNotification object:nil];

	// add our custom flip button as the nav bar's custom right view
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
	flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	self.navigationItem.rightBarButtonItem = flipButton;
	
	// note: the app hasn't finished launching, so we setup the background color later in "updateSettings"
}

- (void)viewDidUnload
{
	self.instructionsView = nil;
	self.doneButton = nil;
	self.flipButton = nil;
}

// this is called when the app finishes launching (i.e. UIApplicationDidFinishLaunchingNotification)
//
- (void)updateSettings:(NSNotification *)notif
{
	// now change the app view's background color
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	switch ([appDelegate backgroundColor])
	{
		case blackBackColor:
			self.tableView.backgroundColor = [UIColor blackColor];
			break;
			
		case whiteBackColor:
			self.tableView.backgroundColor = [UIColor whiteColor];
			break;
		
		case blueBackColor:
			self.tableView.backgroundColor = [UIColor blueColor];
			break;
			
		case patternBackColor:
			self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
			break;
	}
}


#pragma mark - Flip screen

- (void)flipAction:(id)sender
{
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([self.tableView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
							forView:self.tableView cache:YES];
	
	if ([instructionsView superview])
		[instructionsView removeFromSuperview];
	else
		[self.tableView addSubview:instructionsView];

	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([instructionsView superview] == self.tableView)
		self.navigationItem.rightBarButtonItem = doneButton;
	else
		self.navigationItem.rightBarButtonItem = flipButton;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *kCellIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// ask our app delegate for the preferred string values and text color
	NSString *firstNameStr = appDelegate.firstName;
	NSString *lastNameStr = appDelegate.lastName;
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstNameStr, lastNameStr];
	
	switch ([appDelegate textColor])
	{
		case blue:
			cell.textLabel.textColor = [UIColor blueColor];
			break;
			
		case green:
			cell.textLabel.textColor = [UIColor greenColor];
			break;
			
		case red:
			cell.textLabel.textColor = [UIColor redColor];
			break;
	}
	
	return cell;
}

@end

