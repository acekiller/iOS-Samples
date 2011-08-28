
/*
     File: RootViewController.m
 Abstract: View controller to manage a scrollview that displays a zoomable image.
 
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

#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "TapDetectingView.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

#define THUMB_HEIGHT 150
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 20

#define AUTOSCROLL_THRESHOLD 30

@interface RootViewController (ViewHandlingMethods)
- (void)toggleThumbView;
- (void)pickImageNamed:(NSString *)name size:(CGSize)size;
- (NSArray *)imageData;
- (void)createThumbScrollViewIfNecessary;
- (void)createSlideUpViewIfNecessary;
@end

@interface RootViewController (AutoscrollingMethods)
- (void)maybeAutoscrollForThumb:(ThumbImageView *)thumb;
- (void)autoscrollTimerFired:(NSTimer *)timer;
- (void)legalizeAutoscrollDistance;
- (float)autoscrollDistanceForProximityToEdge:(float)proximity;
@end

@interface RootViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end


@implementation RootViewController

- (void)loadView {
    [super loadView];
    
    imageScrollView = [[TiledScrollView alloc] initWithFrame:[[self view] bounds]];
    [imageScrollView setDataSource:self];
    [[imageScrollView tileContainerView] setDelegate:self];
    [imageScrollView setTileSize:CGSizeMake(256, 256)];
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
    [imageScrollView setBouncesZoom:YES];
    [imageScrollView setMaximumResolution:0];
    [imageScrollView setMinimumResolution:-2];

    [[self view] addSubview:imageScrollView];
        
    // we now have to pass the size of the image, because we're not loading the entire image at once
    [self pickImageNamed:@"WeCanDoIt" size:CGSizeMake(1730, 2430)];
}

- (void)dealloc {
    [imageScrollView release];
    [slideUpView release];
    [thumbScrollView release];
    [super dealloc];
}

#pragma mark TiledScrollViewDataSource method

- (UIView *)tiledScrollView:(TiledScrollView *)tiledScrollView tileForRow:(int)row column:(int)column resolution:(int)resolution {

    // re-use a tile rather than creating a new one, if possible
    UIImageView *tile = (UIImageView *)[tiledScrollView dequeueReusableTile];

    if (!tile) {
        // the scroll view will handle setting the tile's frame, so we don't have to worry about it
        tile = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease]; 

        // Some of the tiles won't be completely filled, because they're on the right or bottom edge.
        // By default, the image would be stretched to fill the frame of the image view, but we don't
        // want this. Setting the content mode to "top left" ensures that the images around the edge are
        // positioned properly in their tiles. 
        [tile setContentMode:UIViewContentModeTopLeft]; 
    }
    
    // The resolution is stored as a power of 2, so -1 means 50%, -2 means 25%, and 0 means 100%.
    // We've named the tiles things like BlackLagoon_50_0_2.png, where the 50 represents 50% resolution.
    int resolutionPercentage = 100 * pow(2, resolution);
    [tile setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%d_%d_%d.png", currentImageName, resolutionPercentage, column, row]]];

    return tile;
}

#pragma mark TapDetectingViewDelegate 

- (void)tapDetectingView:(TapDetectingView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    [self toggleThumbView];
}

- (void)tapDetectingView:(TapDetectingView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingView:(TapDetectingView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark ThumbImageViewDelegate
/************************************** NOTE **************************************/
/* For comments on the ThumbImageViewDelegate methods, please see the Autoscroll  */
/* project in this sample code suite.                                             */
/**********************************************************************************/

- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv {
    [self pickImageNamed:[tiv imageName] size:[tiv imageSize]];
    [self toggleThumbView];
}

- (void)thumbImageViewStartedTracking:(ThumbImageView *)tiv {
    [thumbScrollView bringSubviewToFront:tiv];
}

- (void)thumbImageViewMoved:(ThumbImageView *)draggingThumb {
    
    [self maybeAutoscrollForThumb:draggingThumb];
    
    if (CGRectIntersectsRect([draggingThumb frame], [thumbScrollView bounds])) {        
        BOOL draggingRight = [draggingThumb frame].origin.x > [draggingThumb home].origin.x;

        NSMutableArray *thumbsToShift = [[NSMutableArray alloc] init];
        
        CGPoint touchLocation = [draggingThumb convertPoint:[draggingThumb touchLocation] toView:thumbScrollView];
        float minX = draggingRight ? CGRectGetMaxX([draggingThumb home]) : touchLocation.x;
        float maxX = draggingRight ? touchLocation.x : CGRectGetMinX([draggingThumb home]);

        for (ThumbImageView *thumb in [thumbScrollView subviews]) {            
            if (thumb == draggingThumb) continue;
            if (! [thumb isMemberOfClass:[ThumbImageView class]]) continue;
            
            float thumbMidpoint = CGRectGetMidX([thumb home]);
            if (thumbMidpoint >= minX && thumbMidpoint <= maxX) {
                [thumbsToShift addObject:thumb];
            }
        }
        
        float otherThumbShift = ([draggingThumb home].size.width + THUMB_H_PADDING) * (draggingRight ? -1 : 1);
        float draggingThumbShift = 0.0;
        
        for (ThumbImageView *otherThumb in thumbsToShift) {
            CGRect home = [otherThumb home];
            home.origin.x += otherThumbShift;
            [otherThumb setHome:home];
            [otherThumb goHome];
            draggingThumbShift += ([otherThumb frame].size.width + THUMB_H_PADDING) * (draggingRight ? 1 : -1);
        }
        
        CGRect home = [draggingThumb home];
        home.origin.x += draggingThumbShift;
        [draggingThumb setHome:home];
    }
}

- (void)thumbImageViewStoppedTracking:(ThumbImageView *)tiv {
    autoscrollDistance = 0;
    [autoscrollTimer invalidate];
    autoscrollTimer = nil;
}

#pragma mark Autoscrolling
/************************************** NOTE **************************************/
/* For comments on the Autoscrolling methods, please see the Autoscroll project   */
/* in this sample code suite.                                                     */
/**********************************************************************************/

- (void)maybeAutoscrollForThumb:(ThumbImageView *)thumb {
    
    autoscrollDistance = 0;
    
    if (CGRectIntersectsRect([thumb frame], [thumbScrollView bounds])) {
        
        CGPoint touchLocation = [thumb convertPoint:[thumb touchLocation] toView:thumbScrollView];
        float distanceFromLeftEdge  = touchLocation.x - CGRectGetMinX([thumbScrollView bounds]);
        float distanceFromRightEdge = CGRectGetMaxX([thumbScrollView bounds]) - touchLocation.x;
        
        if (distanceFromLeftEdge < AUTOSCROLL_THRESHOLD) {
            autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromLeftEdge] * -1;
        } else if (distanceFromRightEdge < AUTOSCROLL_THRESHOLD) {
            autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromRightEdge];
        }        
    }
    
    if (autoscrollDistance == 0) {
        [autoscrollTimer invalidate];
        autoscrollTimer = nil;
    } 
    else if (autoscrollTimer == nil) {
        autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0)
                                                           target:self 
                                                         selector:@selector(autoscrollTimerFired:) 
                                                         userInfo:thumb 
                                                          repeats:YES];
    } 
}

- (float)autoscrollDistanceForProximityToEdge:(float)proximity {
    return ceilf((AUTOSCROLL_THRESHOLD - proximity) / 5.0);
}

- (void)legalizeAutoscrollDistance {
    float minimumLegalDistance = [thumbScrollView contentOffset].x * -1;
    float maximumLegalDistance = [thumbScrollView contentSize].width - ([thumbScrollView frame].size.width + [thumbScrollView contentOffset].x);
    autoscrollDistance = MAX(autoscrollDistance, minimumLegalDistance);
    autoscrollDistance = MIN(autoscrollDistance, maximumLegalDistance);
}

- (void)autoscrollTimerFired:(NSTimer*)timer {
    [self legalizeAutoscrollDistance];
    
    CGPoint contentOffset = [thumbScrollView contentOffset];
    contentOffset.x += autoscrollDistance;
    [thumbScrollView setContentOffset:contentOffset];
    
    ThumbImageView *thumb = (ThumbImageView *)[timer userInfo];
    [thumb moveByOffset:CGPointMake(autoscrollDistance, 0)];
}

#pragma mark View handling methods

- (void)pickImageNamed:(NSString *)name size:(CGSize)size {
    
    [currentImageName release];
    currentImageName = [name retain];
    
    // change the content size and reset the state of the scroll view
    // to avoid interactions with different zoom scales and resolutions. 
    [imageScrollView reloadDataWithNewContentSize:size];
    [imageScrollView setContentOffset:CGPointZero];
    
    // choose minimum scale so image width fills screen
    float minScale = [imageScrollView frame].size.width  / size.width;
    [imageScrollView setMinimumZoomScale:minScale];
    [imageScrollView setZoomScale:minScale];    
}

- (void)toggleThumbView {
    [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
    CGRect frame = [slideUpView frame];
    if (thumbViewShowing) {
        frame.origin.y += frame.size.height;
    } else {
        frame.origin.y -= frame.size.height;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [slideUpView setFrame:frame];
    [UIView commitAnimations];
    
    thumbViewShowing = !thumbViewShowing;
}

- (NSArray *)imageData {
            
    // the filenames are stored in a plist in the app bundle, so create array by reading this plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ImageData" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSString *error; NSPropertyListFormat format;
    NSArray *imageData = [NSPropertyListSerialization propertyListFromData:plistData
                                                          mutabilityOption:NSPropertyListImmutable
                                                                    format:&format
                                                          errorDescription:&error];
    if (!imageData) {
        NSLog(@"Failed to read image names. Error: %@", error);
        [error release];
    }
        
    return imageData;
}

- (void)createSlideUpViewIfNecessary {
    
    if (!slideUpView) {
        
        // create thumb scroll view
        [self createThumbScrollViewIfNecessary];

        CGRect bounds = [[self view] bounds];
        float thumbHeight = [thumbScrollView frame].size.height;
        float labelHeight = CREDIT_LABEL_HEIGHT;

        // create label giving credit for images
        UILabel *creditLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbHeight, bounds.size.width, labelHeight)];
        [creditLabel setBackgroundColor:[UIColor clearColor]];
        [creditLabel setTextColor:[UIColor whiteColor]];
        [creditLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
        [creditLabel setText:@"images courtesy of the american legion"];
        [creditLabel setTextAlignment:UITextAlignmentCenter];        
        
        // create container view that will hold scroll view and label
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, thumbHeight + labelHeight);
        slideUpView = [[UIView alloc] initWithFrame:frame];
        [slideUpView setBackgroundColor:[UIColor blackColor]];
        [slideUpView setOpaque:NO];
        [slideUpView setAlpha:0.75];
        [[self view] addSubview:slideUpView];
        
        // add subviews to container view
        [slideUpView addSubview:thumbScrollView];
        [slideUpView addSubview:creditLabel];
        [creditLabel release];        
    }    
}

- (void)createThumbScrollViewIfNecessary {
    
    if (!thumbScrollView) {        
        
        float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
        float scrollViewWidth  = [[self view] bounds].size.width;
        thumbScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
        [thumbScrollView setBackgroundColor:nil];
        [thumbScrollView setCanCancelContentTouches:NO];
        [thumbScrollView setClipsToBounds:NO];
        
        // now place all the thumb views as subviews of the scroll view 
        // and in the course of doing so calculate the content width
        float xPosition = THUMB_H_PADDING;
        for (NSDictionary *imageDict in [self imageData]) {
            NSString *name = [imageDict valueForKey:@"name"];
            UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_thumb.png", name]];
            if (thumbImage) {
                ThumbImageView *thumbView = [[ThumbImageView alloc] initWithImage:thumbImage];
                [thumbView setDelegate:self];
                [thumbView setImageName:name];
                [thumbView setImageSize:CGSizeMake([[imageDict valueForKey:@"width"] floatValue], [[imageDict valueForKey:@"height"] floatValue])]; 
                CGRect frame = [thumbView frame];
                frame.origin.y = THUMB_V_PADDING;
                frame.origin.x = xPosition;
                [thumbView setFrame:frame];
                [thumbView setHome:frame];
                [thumbScrollView addSubview:thumbView];
                [thumbView release];
                xPosition += (frame.size.width + THUMB_H_PADDING);
            }
        }
        [thumbScrollView setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    }    
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
