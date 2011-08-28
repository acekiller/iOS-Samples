/*
     File: WeatherServer.m
 Abstract: Manages and serves all weather locations backed by Core Data.
 
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

#import "WeatherServer.h"
#import "WeatherItem.h"


@implementation WeatherServer

- (void)dealloc
{
    [managedObjectContext release];
    [persistentStoreCoordinator release];
	[super dealloc];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext == nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"WeatherItem" inManagedObjectContext:self.managedObjectContext]];
        NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedItems.count == 0)
        {
            // fill in the new WeatherMap.sqlite found in the application's Documents directory
            NSManagedObjectContext *moc = self.managedObjectContext;
            NSEntityDescription *ent = [NSEntityDescription entityForName:@"WeatherItem" inManagedObjectContext:moc];
            WeatherItem *item = nil;
            
            item = [[WeatherItem alloc] initWithEntity:ent insertIntoManagedObjectContext:moc];
            item.place = @"S.F.";
            item.latitude = [NSNumber numberWithDouble:37.779941];
            item.longitude = [NSNumber numberWithDouble:-122.417908];
            item.high = [NSNumber numberWithInteger:80];
            item.low = [NSNumber numberWithInteger:50];
            item.condition = [NSNumber numberWithInteger:Sunny];
            [item release]; // release the item - the context itself retains the necessary data
            
            item = [[WeatherItem alloc] initWithEntity:ent insertIntoManagedObjectContext:moc];
            item.place = @"Denver";
            item.latitude = [NSNumber numberWithDouble:39.752601];
            item.longitude = [NSNumber numberWithDouble:-104.982605];
            item.high = [NSNumber numberWithInteger:40];
            item.low = [NSNumber numberWithInteger:30];
            item.condition = [NSNumber numberWithInteger:Snow];
            [item release];
            
            item = [[WeatherItem alloc] initWithEntity:ent insertIntoManagedObjectContext:moc];
            item.place = @"Chicago";
            item.latitude = [NSNumber numberWithDouble:41.863425];
            item.longitude = [NSNumber numberWithDouble:-87.652359];
            item.high = [NSNumber numberWithInteger:45];
            item.low = [NSNumber numberWithInteger:29];
            item.condition = [NSNumber numberWithInteger:Snow];
            [item release];
            
            item = [[WeatherItem alloc] initWithEntity:ent insertIntoManagedObjectContext:moc];
            item.place = @"Seattle";
            item.latitude = [NSNumber numberWithDouble:47.615884];
            item.longitude = [NSNumber numberWithDouble:-122.332764];
            item.high = [NSNumber numberWithInteger:75];
            item.low = [NSNumber numberWithInteger:45];
            item.condition = [NSNumber numberWithInteger:Sunny];
            [item release];
            
            NSError *err;
            [moc save:&err];
        }
        [fetchRequest release];
    }
    
    return managedObjectContext;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator == nil)
    {
        // apply a store URL to our persistentStoreCoordinator, which will create a new WeatherMap.sqlite file if necessary
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *weatherMapPath = [[paths lastObject] stringByAppendingPathComponent:@"WeatherMap.sqlite"];
        NSURL *storeUrl = [NSURL fileURLWithPath:weatherMapPath];

        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSError *error = nil;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible
             * The schema for the persistent store is incompatible with current managed object model
             Check the error message to determine what the actual problem was.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    return persistentStoreCoordinator;
}

- (NSArray *)weatherItemsForMapRegion:(MKCoordinateRegion)region maximumCount:(NSInteger)maxCount
{
    NSMutableArray *weatherItems = [NSMutableArray array];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"WeatherItem" inManagedObjectContext:self.managedObjectContext]];
    
    NSNumber *latitudeStart = [NSNumber numberWithDouble:region.center.latitude - region.span.latitudeDelta/2.0];
    NSNumber *latitudeStop = [NSNumber numberWithDouble:region.center.latitude + region.span.latitudeDelta/2.0];
    NSNumber *longitudeStart = [NSNumber numberWithDouble:region.center.longitude - region.span.longitudeDelta/2.0];
    NSNumber *longitudeStop = [NSNumber numberWithDouble:region.center.longitude + region.span.longitudeDelta/2.0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude>%@ AND latitude<%@ AND longitude>%@ AND longitude<%@", latitudeStart, latitudeStop, longitudeStart, longitudeStop];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    [sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:@"latitude" ascending:YES] autorelease]];
    [sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:@"longitude" ascending:YES] autorelease]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"latitude", @"longitude", @"place", nil]];
    NSError *error = nil;
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil)
    {
        // an error occurred
        NSLog(@"fetch request resulted in an error %@, %@", error, [error userInfo]);
    }
    else
    {
        NSInteger countOfFetchedItems = [fetchedItems count];
        if (countOfFetchedItems > maxCount) {
            float index = 0, stride = (float)(countOfFetchedItems - 1)/ (float)maxCount;
            NSInteger countOfItemsToReturn = 0;
            while (countOfItemsToReturn < maxCount)
            {
                [weatherItems addObject:[fetchedItems objectAtIndex:(NSInteger)index]];
                index += stride;
                countOfItemsToReturn++;
            }
        }
        else
        {
            [weatherItems addObjectsFromArray:fetchedItems];
        }
    }
    [fetchRequest release];
    return weatherItems;
}

@end
