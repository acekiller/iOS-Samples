/*
     File: SongsViewController.m
 Abstract: Lists all songs in a table view. Also allows sorting and grouping via bottom segmented control.
  Version: 1.1
 
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

#import "SongsViewController.h"
#import "SongDetailsController.h"
#import "Song.h"

@implementation SongsViewController

@synthesize managedObjectContext, tableView, fetchSectioningControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    self.navigationItem.hidesBackButton = YES;
    [self fetch];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
    self.fetchSectioningControl = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    [fetchedResultsController release];
    [managedObjectContext release];
    [detailController release];
    [tableView release];
    [fetchSectioningControl release];
    [super dealloc];
}

- (SongDetailsController *)detailController {
    if (detailController == nil) {
        detailController = [[SongDetailsController alloc] initWithNibName:@"SongDetailsView" bundle:nil];
    }
    return detailController;
}

- (void)handleSaveNotification:(NSNotification *)aNotification {
    [managedObjectContext mergeChangesFromContextDidSaveNotification:aNotification];
    [self fetch];
}

- (IBAction)changeFetchSectioning:(id)sender {
    [fetchedResultsController release];
    fetchedResultsController = nil;
    [self fetch];
}

- (void)fetch {
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    NSAssert2(success, @"Unhandled error performing fetch at SongsViewController.m, line %d: %@", __LINE__, [error localizedDescription]);
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Song" inManagedObjectContext:managedObjectContext]];
        NSArray *sortDescriptors = nil;
        NSString *sectionNameKeyPath = nil;
        if ([fetchSectioningControl selectedSegmentIndex] == 1) {
            sortDescriptors = [NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"category.name" ascending:YES] autorelease], [[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES] autorelease], nil];
            sectionNameKeyPath = @"category.name";
        } else {
            sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES] autorelease]];
        }
        [fetchRequest setSortDescriptors:sortDescriptors];
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:@"SongsCache"];
    }    
    return fetchedResultsController;
}    

#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    if ([fetchSectioningControl selectedSegmentIndex] == 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"Top %d songs", @"Top %d songs"), [sectionInfo numberOfObjects]];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"%@ - %d songs", @"%@ - %d songs"), [sectionInfo name], [sectionInfo numberOfObjects]];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    return [fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    // tell table which section corresponds to section title/index (e.g. "B",1))
    return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"SongCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    Song *song = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"#%d %@", @"#%d %@"), [song.rank integerValue], song.title];
    return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [table deselectRowAtIndexPath:indexPath animated:YES];
    self.detailController.song = [fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:self.detailController animated:YES];
}

@end
