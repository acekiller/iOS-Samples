/*
     File: SeismicXMLAppDelegate.m
 Abstract: Delegate for the application, initiates the download of the XML data and parses the Earthquake objects at launch time.
  Version: 1.8
 
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

#import "SeismicXMLAppDelegate.h"
#import "RootViewController.h"
#import "Earthquake.h"
// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>


@implementation SeismicXMLAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize earthquakeList;
@synthesize earthquakeFeedConnection;
@synthesize earthquakeData;
@synthesize currentEarthquakeObject;
@synthesize currentParsedCharacterData;
@synthesize currentParseBatch;

- (void)dealloc {
    [earthquakeFeedConnection release];
    [earthquakeData release];
	[navigationController release];
    [rootViewController release];
	[window release];
	[earthquakeList release];
    [currentEarthquakeObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Initialize the array of earthquakes and pass a reference to that list to the Root view controller.
    self.earthquakeList = [NSMutableArray array];
    rootViewController.earthquakeList = earthquakeList;
	// Add the navigation view controller to the window.
	[window addSubview:navigationController.view];
    
    // Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the
    // application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked! Also, avoid synchronous network access on any thread.
    //
    static NSString *feedURLString = @"http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml";
    NSURLRequest *earthquakeURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.earthquakeFeedConnection = [[[NSURLConnection alloc] initWithRequest:earthquakeURLRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object to be nil is a malformed
    // URL, which is a programmatic error easily detected during development. If the URL is more dynamic, then you should
    // implement a more flexible validation technique, and be able to both recover from errors and communicate problems
    // to the user in an unobtrusive manner.
    NSAssert(self.earthquakeFeedConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.earthquakeData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [earthquakeData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error",                             @"Error message displayed when not connected to the Internet.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.earthquakeFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.earthquakeFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    // Spawn a thread to fetch the earthquake data so that the UI is not blocked while the application parses the XML data.
    //
    // IMPORTANT! - Don't access UIKit objects on secondary threads.
    //
    [NSThread detachNewThreadSelector:@selector(parseEarthquakeData:) toTarget:self withObject:earthquakeData];
    // earthquakeData will be retained by the thread until parseEarthquakeData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    self.earthquakeData = nil;
}

- (void)parseEarthquakeData:(NSData *)data {
    // You must create a autorelease pool for all secondary threads.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    //
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable
    // because it gives less control over the network, particularly in responding to connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];

    // depending on the total number of earthquakes parsed, the last batch might not have been a "full" batch, and thus
    // not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addEarthquakesToList:) withObject:self.currentParseBatch waitUntilDone:NO];
    }
    self.currentParseBatch = nil;
    self.currentEarthquakeObject = nil;
    self.currentParsedCharacterData = nil;
    [parser release];        
    [pool release];
}

// Handle errors in the download or the parser by showing an alert to the user. This is a very simple way of handling the error,
// partly because this application does not have any offline functionality for the user. Most real applications should
// handle the error in a less obtrusive way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

// The secondary (parsing) thread calls addToEarthquakeList: on the main thread with batches of parsed objects. 
// The batch size is set via the kSizeOfEarthquakeBatch constant.
- (void)addEarthquakesToList:(NSArray *)earthquakes {
    [self.earthquakeList addObjectsFromArray:earthquakes];
    // The table needs to be reloaded to reflect the new content of the list.
    [rootViewController.tableView reloadData];
}

#pragma mark Parser constants

// Limit the number of parsed earthquakes to 50.
static const const NSUInteger kMaximumNumberOfEarthquakesToParse = 50;

// When an Earthquake object has been fully constructed, it must be passed to the main thread and the table view 
// in RootViewController must be reloaded to display it. It is not efficient to do this for every Earthquake object -
// the overhead in communicating between the threads and reloading the table exceed the benefit to the user. Instead,
// we pass the objects in batches, sized by the constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
static NSUInteger const kSizeOfEarthquakeBatch = 10;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kEntryElementName = @"entry";
static NSString * const kLinkElementName = @"link";
static NSString * const kTitleElementName = @"title";
static NSString * const kUpdatedElementName = @"updated";
static NSString * const kGeoRSSPointElementName = @"georss:point";

#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // If the number of parsed earthquakes is greater than kMaximumNumberOfEarthquakesToParse, abort the parse.
    if (parsedEarthquakesCounter >= kMaximumNumberOfEarthquakesToParse) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
        didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kEntryElementName]) {
        Earthquake *earthquake = [[Earthquake alloc] init];
        self.currentEarthquakeObject = earthquake;
        [earthquake release];
    } else if ([elementName isEqualToString:kLinkElementName]) {
        NSString *relAttribute = [attributeDict valueForKey:@"rel"];
        if ([relAttribute isEqualToString:@"alternate"]) {
            NSString *USGSWebLink = [attributeDict valueForKey:@"href"];
            static NSString * const kUSGSBaseURL = @"http://earthquake.usgs.gov/";
            self.currentEarthquakeObject.USGSWebLink = [kUSGSBaseURL stringByAppendingString:USGSWebLink];
        }
    } else if ([elementName isEqualToString:kTitleElementName] || [elementName isEqualToString:kUpdatedElementName] || [elementName isEqualToString:kGeoRSSPointElementName]) {
        // For the 'title', 'updated', or 'georss:point' element, begin accumulating parsed character data.
        // The contents are collected in parser:foundCharacters:.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    if ([elementName isEqualToString:kEntryElementName]) {
        [self.currentParseBatch addObject:self.currentEarthquakeObject];
        parsedEarthquakesCounter++;
        if (parsedEarthquakesCounter % kSizeOfEarthquakeBatch == 0) {
            [self performSelectorOnMainThread:@selector(addEarthquakesToList:) withObject:self.currentParseBatch waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    } else if ([elementName isEqualToString:kTitleElementName]) {
        // The title element contains the magnitude and location in the following format:
        // <title>M 3.6, Virgin Islands region<title/>
        // Extract the magnitude and the location using a scanner:
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        // Scan past the "M " before the magnitude.
        [scanner scanString:@"M " intoString:NULL];
        CGFloat magnitude;
        [scanner scanFloat:&magnitude];
        self.currentEarthquakeObject.magnitude = magnitude;
        // Scan past the ", " before the title.
        [scanner scanString:@", " intoString:NULL];
        NSString *location = nil;
        // Scan the remainer of the string.
        [scanner scanUpToCharactersFromSet:[NSCharacterSet illegalCharacterSet]  intoString:&location];
        self.currentEarthquakeObject.location = location;
    } else if ([elementName isEqualToString:kUpdatedElementName]) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.currentEarthquakeObject.date = [dateFormatter dateFromString:self.currentParsedCharacterData];
    } else if ([elementName isEqualToString:kGeoRSSPointElementName]) {
        // The georss:point element contains the latitude and longitude of the earthquake epicenter.
        // 18.6477 -66.7452
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        double latitude, longitude;
        [scanner scanDouble:&latitude];
        [scanner scanDouble:&longitude];
        self.currentEarthquakeObject.latitude = latitude;
        self.currentEarthquakeObject.longitude = longitude;
    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not
// guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to
// accumulate character data until the end of the element is reached.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.currentParsedCharacterData appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // If the number of earthquake records received is greater than kMaximumNumberOfEarthquakesToParse, we abort parsing.
    // The parser will report this as an error, but we don't want to treat it as an error. The flag didAbortParsing is
    // how we distinguish real errors encountered by the parser.
    if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
