
/*
     File: PreferencesViewController.m
 Abstract: The PreferencesViewController object manages the views that make up the Metronome application preferences UI.
 
  Version: 2.2
 
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

#import "PreferencesViewController.h"
#import "MetronomeViewController.h"
#import "MetronomeAppDelegate.h"

@implementation PreferencesViewController


@synthesize delegate;


#pragma mark -
#pragma mark === Action method ===
#pragma mark -

- (IBAction)done {
	[self.delegate preferencesViewControllerDidFinish:self];	
}


#pragma mark -
#pragma mark === View configuration ===
#pragma mark -

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	
	if (self = [super initWithNibName:nibName bundle:nibBundle]) {
		self.wantsFullScreenLayout = YES;
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark === TableView datasource and delegate methods ===
#pragma mark -

/*
 Provide cells for the table, with each showing one of the available time signatures.
 */

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	MetronomeAppDelegate *appDelegate = (MetronomeAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.timeSignatures count];
}


- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *reuseIdentifier = @"PreferencesCellIdentifier";
	
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
    }
	
	MetronomeAppDelegate *appDelegate = (MetronomeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    cell.textLabel.text = [appDelegate.timeSignatures objectAtIndex:indexPath.row];
	if (([appDelegate timeSignature] - 2) == indexPath.row) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // This table has only one section.
    return NSLocalizedString(@"Time Signature", @"Title for table that display time signatures");
}



- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {

	// When a new selection is made, display a check mark on the newly-selected time signature and remove check mark from old time signature.

	MetronomeAppDelegate *appDelegate = (MetronomeAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:([appDelegate timeSignature] - 2) inSection:0];
	
    [[table cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
    [[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
	
    if (newIndexPath.row == 0) {
        [appDelegate setTimeSignature:TimeSignatureTwoFour];
    }
	else if (newIndexPath.row == 1) {
        [appDelegate setTimeSignature:TimeSignatureThreeFour];
    }
	else {
        [appDelegate setTimeSignature:TimeSignatureFourFour];
    }
}


@end
