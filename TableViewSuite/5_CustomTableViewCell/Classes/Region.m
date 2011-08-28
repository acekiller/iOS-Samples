
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


static NSMutableDictionary *regions;

@implementation Region

@synthesize name;
@synthesize  timeZoneWrappers;
@synthesize  calendar;

/*
 Class methods to manage global regions.
 */
+ (void)initialize {
	regions = [[NSMutableDictionary alloc] init];	
}


+ (Region *)regionNamed:(NSString *)name {
	return [regions objectForKey:name];
}


+ (Region *)newRegionWithName:(NSString *)regionName {
    // Create a new region with a given name; add it to the regions dictionary.
	Region *newRegion = [[Region alloc] init];
	newRegion.name = regionName;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	newRegion.timeZoneWrappers = array;
	[array release];
	[regions setObject:newRegion forKey:regionName];
	return newRegion;
}


- (void)addTimeZone:(NSTimeZone *)timeZone nameComponents:(NSArray *)nameComponents {
    // Add a time zone to the region; use nameComponents since that's expensive to compute.
	TimeZoneWrapper *timeZoneWrapper = [[TimeZoneWrapper alloc] initWithTimeZone:timeZone nameComponents:nameComponents];
	timeZoneWrapper.calendar = calendar;
	[timeZoneWrappers addObject:timeZoneWrapper];
	[timeZoneWrapper release];
}


- (void)sortZones {
    // Sort the zone wrappers by locale name.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeZoneLocaleName" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[timeZoneWrappers sortUsingDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
}


// Sets the date for the time zones, which has the side-effect of "faulting" the wrappers (see TimeZoneWrapper's setDate: method).
- (void)setDate:(NSDate *)date {
	for (TimeZoneWrapper *wrapper in timeZoneWrappers) {
		wrapper.date = date;
	}
}


- (void)dealloc {
	[name release];
	[timeZoneWrappers release];
	[calendar release];
	[super dealloc];
}


@end
