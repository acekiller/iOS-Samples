/*
    File:       PutController.m

    Contains:   Manages the PUT tab.

    Written by: DTS

    Copyright:  Copyright (c) 2009 Apple Inc. All Rights Reserved.

    Disclaimer: IMPORTANT: This Apple software is supplied to you by Apple Inc.
                ("Apple") in consideration of your agreement to the following
                terms, and your use, installation, modification or
                redistribution of this Apple software constitutes acceptance of
                these terms.  If you do not agree with these terms, please do
                not use, install, modify or redistribute this Apple software.

                In consideration of your agreement to abide by the following
                terms, and subject to these terms, Apple grants you a personal,
                non-exclusive license, under Apple's copyrights in this
                original Apple software (the "Apple Software"), to use,
                reproduce, modify and redistribute the Apple Software, with or
                without modifications, in source and/or binary forms; provided
                that if you redistribute the Apple Software in its entirety and
                without modifications, you must retain this notice and the
                following text and disclaimers in all such redistributions of
                the Apple Software. Neither the name, trademarks, service marks
                or logos of Apple Inc. may be used to endorse or promote
                products derived from the Apple Software without specific prior
                written permission from Apple.  Except as expressly stated in
                this notice, no other rights or licenses, express or implied,
                are granted by Apple herein, including but not limited to any
                patent rights that may be infringed by your derivative works or
                by other works in which the Apple Software may be incorporated.

                The Apple Software is provided by Apple on an "AS IS" basis. 
                APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
                WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT,
                MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING
                THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
                COMBINATION WITH YOUR PRODUCTS.

                IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT,
                INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
                TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
                DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY
                OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
                OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY
                OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR
                OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF
                SUCH DAMAGE.

*/

#import "PutController.h"

#import "AppDelegate.h"

#if TARGET_IPHONE_SIMULATOR
    static NSString * kDefaultPutURLText = @"http://localhost:9000/";
#else
    static NSString * kDefaultPutURLText = @"";
#endif

@interface PutController ()

// Properties that don't need to be seen by the outside world.

@property (nonatomic, readonly) BOOL              isSending;
@property (nonatomic, retain)   NSURLConnection * connection;
@property (nonatomic, retain)   NSInputStream *   fileStream;

@end

@implementation PutController

#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)_sendDidStart
{
    self.statusLabel.text = @"Sending";
    self.cancelButton.enabled = YES;
    [self.activityIndicator startAnimating];
    [[AppDelegate sharedAppDelegate] didStartNetworking];
}

- (void)_updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
    self.statusLabel.text = statusString;
}

- (void)_sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"PUT succeeded";
    }
    self.statusLabel.text = statusString;
    self.cancelButton.enabled = NO;
    [self.activityIndicator stopAnimating];
    [[AppDelegate sharedAppDelegate] didStopNetworking];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

@synthesize connection    = _connection;
@synthesize fileStream    = _fileStream;

- (BOOL)isSending
{
    return (self.connection != nil);
}

- (void)_startSend:(NSString *)filePath
{
    BOOL                    success;
    NSURL *                 url;
    NSMutableURLRequest *   request;
    NSNumber *              contentLength;
    
    assert(filePath != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    assert( [filePath.pathExtension isEqual:@"png"] || [filePath.pathExtension isEqual:@"jpg"] );
    
    assert(self.connection == nil);         // don't tap send twice in a row!
    assert(self.fileStream == nil);         // ditto

    // First get and check the URL.
    
    url = [[AppDelegate sharedAppDelegate] smartURLForString:self.urlText.text];
    success = (url != nil);
    
    if (success) {
        // Add the last the file name to the end of the URL to form the final 
        // URL that we're going to PUT to.
        
        url = [NSMakeCollectable(
            CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef) url, (CFStringRef) [filePath lastPathComponent], false)
        ) autorelease];
        success = (url != nil);
    }
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.

    if ( ! success) {
        self.statusLabel.text = @"Invalid URL";
    } else {

        // Open a stream for the file we're going to send.  We do not open this stream; 
        // NSURLConnection will do it for us.
        
        self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
        assert(self.fileStream != nil);
        
        // Open a connection for the URL, configured to PUT the file.

        request = [NSMutableURLRequest requestWithURL:url];
        assert(request != nil);
        
        [request setHTTPMethod:@"PUT"];
        [request setHTTPBodyStream:self.fileStream];
        
        if ( [filePath.pathExtension isEqual:@"png"] ) {
            [request setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
        } else if ( [filePath.pathExtension isEqual:@"jpg"] ) {
            [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        } else if ( [filePath.pathExtension isEqual:@"gif"] ) {
            [request setValue:@"image/gif" forHTTPHeaderField:@"Content-Type"];
        } else {
            assert(NO);
        }

        contentLength = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] objectForKey:NSFileSize];
        assert( [contentLength isKindOfClass:[NSNumber class]] );
        [request setValue:[contentLength description] forHTTPHeaderField:@"Content-Length"];
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
        
        // Tell the UI we're sending.
        
        [self _sendDidStart];
    }
}

- (void)_stopSendWithStatus:(NSString *)statusString
{
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self _sendDidStopWithStatus:statusString];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
    // A delegate method called by the NSURLConnection when the request/response 
    // exchange is complete.  We look at the response to check that the HTTP 
    // status code is 2xx.  If it isn't, we fail right now.
{
    #pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;

    assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self _stopSendWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        self.statusLabel.text = @"Response OK.";
    }    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
    // A delegate method called by the NSURLConnection as data arrives.  The 
    // response data for a PUT is only for useful for debugging purposes, 
    // so we just drop it on the floor.
{
    #pragma unused(theConnection)
    #pragma unused(data)

    assert(theConnection == self.connection);

    // do nothing
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
    // A delegate method called by the NSURLConnection if the connection fails. 
    // We shut down the connection and display the failure.  Production quality code 
    // would either display or log the actual error.
{
    #pragma unused(theConnection)
    #pragma unused(error)
    assert(theConnection == self.connection);
    
    [self _stopSendWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
    // A delegate method called by the NSURLConnection when the connection has been 
    // done successfully.  We shut down the connection with a nil status, which 
    // causes the image to be displayed.
{
    #pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self _stopSendWithStatus:nil];
}

#pragma mark * Actions

- (IBAction)sendAction:(UIView *)sender
{
    assert( [sender isKindOfClass:[UIView class]] );

    if ( ! self.isSending ) {
        NSString *  filePath;
        
        // User the tag on the UIButton to determine which image to send.
        
        filePath = [[AppDelegate sharedAppDelegate] pathForTestImage:sender.tag];
        assert(filePath != nil);
        
        [self _startSend:filePath];
    }
}

- (IBAction)cancelAction:(id)sender
{
    #pragma unused(sender)
    [self _stopSendWithStatus:@"Cancelled"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
    // A delegate method called by the URL text field when the editing is complete. 
    // We save the current value of the field in our settings.
{
    #pragma unused(textField)
    NSString *  newValue;
    NSString *  oldValue;
    
    assert(textField == self.urlText);

    newValue = self.urlText.text;
    oldValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"PutURLText"];

    // Save the URL text if there is no pre-existing setting and it's not our 
    // default value, or if there is a pre-existing default and the new value 
    // is different.
    
    if (   ((oldValue == nil) && ! [newValue isEqual:kDefaultPutURLText] ) 
        || ((oldValue != nil) && ! [newValue isEqual:oldValue] ) ) {
        [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:@"PutURLText"];
    }    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
    // A delegate method called by the URL text field when the user taps the Return 
    // key.  We just dismiss the keyboard.
{
    #pragma unused(textField)
    assert(textField == self.urlText);
    [self.urlText resignFirstResponder];
    return NO;
}

#pragma mark * View controller boilerplate

@synthesize urlText           = _urlText;
@synthesize statusLabel       = _statusLabel;
@synthesize activityIndicator = _activityIndicator;
@synthesize cancelButton      = _cancelButton;

- (void)viewDidLoad
{
    NSString *  currentURLText;
    
    [super viewDidLoad];
    assert(self.urlText != nil);
    assert(self.statusLabel != nil);
    assert(self.activityIndicator != nil);
    assert(self.cancelButton != nil);

    // Set up the URL field to be the last value we saved (or the default value 
    // if we have none).
    
    currentURLText = [[NSUserDefaults standardUserDefaults] stringForKey:@"PutURLText"];
    if (currentURLText == nil) {
        currentURLText = kDefaultPutURLText;
    }
    self.urlText.text = currentURLText;
    
    self.activityIndicator.hidden = YES;
    self.statusLabel.text = @"Tap a picture to start the PUT";
    self.cancelButton.enabled = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.urlText = nil;
    self.statusLabel = nil;
    self.activityIndicator = nil;
    self.cancelButton = nil;
}

- (void)dealloc
{
    [self _stopSendWithStatus:@"Stopped"];

    [self->_urlText release];
    [self->_statusLabel release];
    [self->_activityIndicator release];
    [self->_cancelButton release];

    [super dealloc];
}

@end
