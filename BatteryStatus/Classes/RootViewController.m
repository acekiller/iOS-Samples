/*
 
 File: RootViewController.m
 
 Abstract: Controller for initial window. Receives battery status change notifications. Queries the
 battery status and presents it in a UITableView. Enables and disables battery status updates.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
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

@implementation RootViewController

enum ControlTableSections
{
	kMonitoringSection = 0,
	kLevelSection,
	kBatteryStateSection
};

- (void)dealloc
{
	[numberFormatter release];
	[super dealloc];
}

- (void)viewDidLoad
{	
	[super viewDidLoad];
	
	// This title will appear in the navigation bar
	self.title = NSLocalizedString(@"Battery Status", @"");
	
	// Register for battery level and state change notifications.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryLevelDidChange:)
												 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryStateDidChange:)
												 name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

- (NSNumberFormatter *)numberFormatter
{
    if (numberFormatter == nil)
    {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        [numberFormatter setMaximumFractionDigits:1];
    }
    return numberFormatter;
}

#pragma mark - Switch action handler

- (void)switchAction:(id)sender
{
    if ([sender isOn])
    {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
		// The UI will be updated as a result of the first notification.
    }
    else {
        [UIDevice currentDevice].batteryMonitoringEnabled = NO;
		[self.tableView reloadData];
    }
}

#pragma mark - Battery notifications

- (void)batteryLevelDidChange:(NSNotification *)notification
{
	[self.tableView reloadData];
}


- (void)batteryStateDidChange:(NSNotification *)notification
{
	[self.tableView reloadData];
}


#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
	switch (section)
	{
		case kBatteryStateSection:
		{
			title = NSLocalizedString(@"Battery State", @"");
			break;
		}
	}
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rowCount = 1;
	
	if (section == kBatteryStateSection)
	{
		rowCount = 4;
	}
	
	return rowCount;
}

static NSInteger kLevelTag = 2;

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *kMonitoringCellIdentifier = @"Monitoring";
	static NSString *kLevelCellIdentifier = @"Level";
	static NSString *kStateCellIdentifier = @"State";
   
	UITableViewCell *cell = nil;
	
	switch (indexPath.section)
	{
		case kMonitoringSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kMonitoringCellIdentifier];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMonitoringCellIdentifier] autorelease];
				cell.textLabel.text = NSLocalizedString(@"Monitoring", @"");
				
				UISwitch *switchCtl = [[[UISwitch alloc] initWithFrame:CGRectMake(197, 8, 94, 27)] autorelease];
				[switchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
				switchCtl.backgroundColor = [UIColor clearColor];

				[cell.contentView addSubview:switchCtl];
			}
			
			break;
		}
			
		case kLevelSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kLevelCellIdentifier];
			UILabel *levelLabel = nil;
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLevelCellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = NSLocalizedString(@"Level", @"");
				
				levelLabel = [[[UILabel alloc] initWithFrame:CGRectMake(171, 11, 120, 21)] autorelease];
				levelLabel.tag = kLevelTag;
				levelLabel.textAlignment = UITextAlignmentRight;
				[cell.contentView addSubview:levelLabel];
				levelLabel.backgroundColor = [UIColor clearColor];
			}
			else {
				levelLabel = (UILabel *) [cell.contentView viewWithTag:kLevelTag];
			}

			float batteryLevel = [UIDevice currentDevice].batteryLevel;
			if (batteryLevel < 0.0)
			{
				// -1.0 means battery state is UIDeviceBatteryStateUnknown
				levelLabel.text = NSLocalizedString(@"Unknown", @"");
			}
			else {
				NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
				
				// Using the numberFormatter property lazily creates that object the
				// first time it's used. 
				levelLabel.text = [self.numberFormatter stringFromNumber:levelObj];
			}
			break;
		}
			
		case kBatteryStateSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kStateCellIdentifier];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStateCellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StatusClear.png"]] autorelease];
			}
			
			switch (indexPath.row)
			{
				case 0:
				{
					cell.textLabel.text = NSLocalizedString(@"Unknown", @"");
					break;
				}
				case 1:
				{
					cell.textLabel.text = NSLocalizedString(@"Unplugged", @"");
					break;
				}
				case 2:
				{
					cell.textLabel.text = NSLocalizedString(@"Charging", @"");
					break;
				}
				case 3:
				{
					cell.textLabel.text = NSLocalizedString(@"Full", @"");
					break;
				}
			}
				
			UIImageView *statusImageView = (UIImageView *) cell.accessoryView;
			if (indexPath.row + UIDeviceBatteryStateUnknown == [UIDevice currentDevice].batteryState)
			{
				statusImageView.image = [UIImage imageNamed:@"StatusGreen.png"];
			}
			else {
				statusImageView.image = [UIImage imageNamed:@"StatusClear.png"];
			}
			
			break;
		}
	}
    
	// Set attributes common to all cell types.
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}


@end

