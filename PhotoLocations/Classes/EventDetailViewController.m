
/*
     File: EventDetailViewController.m
 Abstract: The table view controller responsible for displaying the time, coordinates, and photo of an event, and allowing the user to select a photo for the event, or delete the existing photo.
 
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
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "EventDetailViewController.h"
#import "Event.h"
#import "Photo.h"


@implementation EventDetailViewController

@synthesize event, timeLabel, coordinatesLabel, photoButton, photoImageView;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	// A date formatter for the creation date.
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	static NSNumberFormatter *numberFormatter;
	if (numberFormatter == nil) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}
	
	timeLabel.text = [dateFormatter stringFromDate:[event creationDate]];
	
	NSString *coordinatesString = [[NSString alloc] initWithFormat:@"%@, %@",
							 [numberFormatter stringFromNumber:[event latitude]],
							 [numberFormatter stringFromNumber:[event longitude]]];
	coordinatesLabel.text = coordinatesString;
	[coordinatesString release];
	
	[self updatePhotoInfo];
}



- (IBAction)editPhoto {
	
	/*
	 Update the photo in response to a tap on the photo button.
	 * If the event already has a photo, delete it
	 * If the event doesn't have a photo, show an image picker to allow the user to choose one
	 */
	
	if (event.photo) {
		/*
		 Delete the Photo object and dispose of the thumbnail.
		 Because the relationship was modeled in both directions, the event's relationship to the photo will automatically be set to nil.
		 */
		NSManagedObjectContext *context = event.managedObjectContext;
		[context deleteObject:event.photo];
		event.thumbnail = nil;
		
		// Commit the change.
		NSError *error;
		if (![event.managedObjectContext save:&error]) {
			// Handle the error.
		}

		// Update the user interface appropriately.
		[self updatePhotoInfo];
	}
	else {
		// Let the user choose a new photo.
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		[self presentModalViewController:imagePicker animated:YES];
		[imagePicker release];
	}
}


- (void)updatePhotoInfo {
	
	// Synchronize the photo image view and the text on the photo button with the event's photo.
	UIImage *image = event.photo.image;

	photoImageView.image = image;
	if (image) {
		photoButton.titleLabel.text = @"Delete Photo";
	}
	else {
		photoButton.titleLabel.text = @"Choose Photo";
	}
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
	
	// Create a new photo object and associate it with the event.
	Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:event.managedObjectContext];
	event.photo = photo;
	
	// Set the image for the photo object.
	photo.image = selectedImage;
	
	// Create a thumbnail version of the image for the event object.
	CGSize size = selectedImage.size;
	CGFloat ratio = 0;
	if (size.width > size.height) {
		ratio = 44.0 / size.width;
	}
	else {
		ratio = 44.0 / size.height;
	}
	CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
	
	UIGraphicsBeginImageContext(rect.size);
	[selectedImage drawInRect:rect];
	event.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	
	// Commit the change.
	NSError *error;
	if (![event.managedObjectContext save:&error]) {
		// Handle the error.
	}
	
	// Update the user interface appropriately.
	[self updatePhotoInfo];

    [self dismissModalViewControllerAnimated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}


- (void)dealloc {
	
	[event release];
	[timeLabel release];
	[coordinatesLabel release];
	[photoButton release];
	[photoImageView release];

    [super dealloc];
}


@end
