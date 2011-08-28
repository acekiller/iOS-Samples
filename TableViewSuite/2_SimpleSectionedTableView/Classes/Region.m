
/*
     File: Region.m
 Abstract: Object to represent a region containing the corresponding time zone wrappers.
 
  Version: 2.1
 
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

#import "Region.h"
#import "TimeZoneWrapper.h"


@interface Region (Private)
- (id)initWithName:(NSString *)regionName;
+ (void)setUpKnownRegions;
- (void)addTimeZoneWrapper:(TimeZoneWrapper *)timeZoneWrapper;
- (void)sortTimeZones;
@end


@implementation Region

@synthesize name, timeZoneWrappers;

static NSMutableArray *knownRegions = nil;


+ (NSArray *)knownRegions {
	
	if (knownRegions == nil) {
		[self setUpKnownRegions];
	}
	return knownRegions;
	
}


#pragma mark -
#pragma mark Memory management.

- (void)dealloc {
	[name release];
	[timeZoneWrappers release];
	[super dealloc];
}


#pragma mark -
#pragma mark Private methods for setting up the regions.

- (id)initWithName:(NSString *)regionName {
	
	if (self = [super init]) {
		name = [regionName copy];
		timeZoneWrappers = [[NSMutableArray alloc] init];
	}
	return self;
}


+ (void)setUpKnownRegions {
	
	NSArray *knownTimeZoneNames = [NSTimeZone knownTimeZoneNames];
	
	NSMutableArray *regions = [[NSMutableArray alloc] initWithCapacity:[knownTimeZoneNames count]];
	
	for (NSString *timeZoneName in knownTimeZoneNames) {
		
		NSArray *nameComponents = [timeZoneName componentsSeparatedByString:@"/"];
		NSString *regionName = [nameComponents objectAtIndex:0];
		
		// Get the region  with the region name, or create it if it doesn't exist.
		Region *region = nil;
		
		for (Region *aRegion in regions) {
			if ([aRegion.name isEqualToString:regionName]) {
				region = aRegion;
				break;
			}
		}
		
		if (region == nil) {
			region = [[Region alloc] initWithName:regionName];
			[regions addObject:region];
			[region release];
		}
		
		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:timeZoneName];
		TimeZoneWrapper *timeZoneWrapper = [[TimeZoneWrapper alloc] initWithTimeZone:timeZone nameComponents:nameComponents];
		[region addTimeZoneWrapper:timeZoneWrapper];
		[timeZoneWrapper release];
	}
	
	// Now sort the time zones by name
	for (Region *aRegion in regions) {
		[aRegion sortTimeZones];
	}
	
	// Sort the regions
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    [regions sortUsingDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	knownRegions = regions;
}	


- (void)addTimeZoneWrapper:(TimeZoneWrapper *)timeZoneWrapper {
	[timeZoneWrappers addObject:timeZoneWrapper];
}


- (void)sortTimeZones {
	
	// Sort the time zones by name
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localeName" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	[timeZoneWrappers sortUsingDescriptors:sortDescriptors];

	[sortDescriptor release];
	[sortDescriptors release];
}	

@end
