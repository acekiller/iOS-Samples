
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

#import "RootViewController.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

#define THUMB_HEIGHT 150
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 20

#define AUTOSCROLL_THRESHOLD 30

@interface RootViewController (ViewHandlingMethods)
- (void)toggleThumbView;
- (void)pickImageNamed:(NSString *)name;
- (NSArray *)imageNames;
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
    
    imageScrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
    [imageScrollView setDelegate:self];
    [imageScrollView setBouncesZoom:YES];
    [[self view] addSubview:imageScrollView];
    
    [self pickImageNamed:@"WeCanDoIt"];
}

- (void)dealloc {
    [imageScrollView release];
    [slideUpView release];
    [thumbScrollView release];
    [super dealloc];
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView *view = nil;
    if (scrollView == imageScrollView) {
        view = [imageScrollView viewWithTag:ZOOM_VIEW_TAG];
    }
    return view;
}

/************************************** NOTE **************************************/
/* The following delegate method works around a known bug in zoomToRect:animated: */
/* In the next release after 3.0 this workaround will no longer be necessary      */
/**********************************************************************************/
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // Single tap shows or hides drawer of thumbnails.
    [self toggleThumbView];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark ThumbImageViewDelegate methods

- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv {
    [self pickImageNamed:[tiv imageName]];
    [self toggleThumbView];
}

- (void)thumbImageViewStartedTracking:(ThumbImageView *)tiv {
    [thumbScrollView bringSubviewToFront:tiv];
}

- (void)thumbImageViewMoved:(ThumbImageView *)draggingThumb {
    
    // check if we've moved close enough to an edge to autoscroll, or far enough away to stop autoscrolling
    [self maybeAutoscrollForThumb:draggingThumb];
        
    /* The rest of this method handles the reordering of thumbnails in the thumbScrollView. See  */
    /* ThumbImageView.h and ThumbImageView.m for more information about how this works.          */
    
    // we'll reorder only if the thumb is overlapping the scroll view
    if (CGRectIntersectsRect([draggingThumb frame], [thumbScrollView bounds])) {        

        BOOL draggingRight = [draggingThumb frame].origin.x > [draggingThumb home].origin.x ? YES : NO;
        
        /* we're going to shift over all the thumbs who live between the home of the moving thumb */
        /* and the current touch location. A thumb counts as living in this area if the midpoint  */
        /* of its home is contained in the area.                                                  */
        NSMutableArray *thumbsToShift = [[NSMutableArray alloc] init];
        
        // get the touch location in the coordinate system of the scroll view
        CGPoint touchLocation = [draggingThumb convertPoint:[draggingThumb touchLocation] toView:thumbScrollView];

        // calculate minimum and maximum boundaries of the affected area
        float minX = draggingRight ? CGRectGetMaxX([draggingThumb home]) : touchLocation.x;
        float maxX = draggingRight ? touchLocation.x : CGRectGetMinX([draggingThumb home]);
        
        // iterate through thumbnails and see which ones need to move over
        for (ThumbImageView *thumb in [thumbScrollView subviews]) {

            // skip the thumb being dragged
            if (thumb == draggingThumb) continue;

            // skip non-thumb subviews of the scroll view (such as the scroll indicators)
            if (! [thumb isMemberOfClass:[ThumbImageView class]]) continue;

            float thumbMidpoint = CGRectGetMidX([thumb home]);
            if (thumbMidpoint >= minX && thumbMidpoint <= maxX) {
                [thumbsToShift addObject:thumb];
            }
        }
        
        // shift over the other thumbs to make room for the dragging thumb. (if we're dragging right, they shift to the left)
        float otherThumbShift = ([draggingThumb home].size.width + THUMB_H_PADDING) * (draggingRight ? -1 : 1);

        // as we shift over the other thumbs, we'll calculate how much the dragging thumb's home is going to move
        float draggingThumbShift = 0.0;
        
        // send each of the shifting thumbs to its new home
        for (ThumbImageView *otherThumb in thumbsToShift) {
            CGRect home = [otherThumb home];
            home.origin.x += otherThumbShift;
            [otherThumb setHome:home];
            [otherThumb goHome];
            draggingThumbShift += ([otherThumb frame].size.width + THUMB_H_PADDING) * (draggingRight ? 1 : -1);
        }
        
        // change the home of the dragging thumb, but don't send it there because it's still being dragged
        CGRect home = [draggingThumb home];
        home.origin.x += draggingThumbShift;
        [draggingThumb setHome:home];
    }
}

- (void)thumbImageViewStoppedTracking:(ThumbImageView *)tiv {
    // if the user lets go of the thumb image view, stop autoscrolling
    [autoscrollTimer invalidate];
    autoscrollTimer = nil;
}

#pragma mark Autoscrolling methods

- (void)maybeAutoscrollForThumb:(ThumbImageView *)thumb {

    autoscrollDistance = 0;
    
    // only autoscroll if the thumb is overlapping the thumbScrollView
    if (CGRectIntersectsRect([thumb frame], [thumbScrollView bounds])) {
        
        CGPoint touchLocation = [thumb convertPoint:[thumb touchLocation] toView:thumbScrollView];
        float distanceFromLeftEdge  = touchLocation.x - CGRectGetMinX([thumbScrollView bounds]);
        float distanceFromRightEdge = CGRectGetMaxX([thumbScrollView bounds]) - touchLocation.x;
        
        if (distanceFromLeftEdge < AUTOSCROLL_THRESHOLD) {
            autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromLeftEdge] * -1; // if scrolling left, distance is negative
        } else if (distanceFromRightEdge < AUTOSCROLL_THRESHOLD) {
            autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromRightEdge];
        }        
    }
    
    // if no autoscrolling, stop and clear timer
    if (autoscrollDistance == 0) {
        [autoscrollTimer invalidate];
        autoscrollTimer = nil;
    } 
    
    // otherwise create and start timer (if we don't already have a timer going)
    else if (autoscrollTimer == nil) {
        autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0)
                                                           target:self 
                                                         selector:@selector(autoscrollTimerFired:) 
                                                         userInfo:thumb 
                                                          repeats:YES];
    } 
}

- (float)autoscrollDistanceForProximityToEdge:(float)proximity {
    // the scroll distance grows as the proximity to the edge decreases, so that moving the thumb
    // further over results in faster scrolling.
    return ceilf((AUTOSCROLL_THRESHOLD - proximity) / 5.0);
}

- (void)legalizeAutoscrollDistance {
    // makes sure the autoscroll distance won't result in scrolling past the content of the scroll view
    float minimumLegalDistance = [thumbScrollView contentOffset].x * -1;
    float maximumLegalDistance = [thumbScrollView contentSize].width - ([thumbScrollView frame].size.width + [thumbScrollView contentOffset].x);
    autoscrollDistance = MAX(autoscrollDistance, minimumLegalDistance);
    autoscrollDistance = MIN(autoscrollDistance, maximumLegalDistance);
}

- (void)autoscrollTimerFired:(NSTimer*)timer {
    [self legalizeAutoscrollDistance];
    
    // autoscroll by changing content offset
    CGPoint contentOffset = [thumbScrollView contentOffset];
    contentOffset.x += autoscrollDistance;
    [thumbScrollView setContentOffset:contentOffset];
    
    // adjust thumb position so it appears to stay still
    ThumbImageView *thumb = (ThumbImageView *)[timer userInfo];
    [thumb moveByOffset:CGPointMake(autoscrollDistance, 0)];
}

#pragma mark View handling methods

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

- (void)pickImageNamed:(NSString *)name {
        
    // first remove previous image view, if any
    [[imageScrollView viewWithTag:ZOOM_VIEW_TAG] removeFromSuperview];
        
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
    TapDetectingImageView *zoomView = [[TapDetectingImageView alloc] initWithImage:image];
    [zoomView setDelegate:self];
    [zoomView setTag:ZOOM_VIEW_TAG];
    [imageScrollView addSubview:zoomView];
    [imageScrollView setContentSize:[zoomView frame].size];
    [zoomView release];
        
    // choose minimum scale so image width fits screen
    float minScale  = [imageScrollView frame].size.width  / [zoomView frame].size.width;
    [imageScrollView setMinimumZoomScale:minScale];
    [imageScrollView setZoomScale:minScale];
    [imageScrollView setContentOffset:CGPointZero];
}

- (NSArray *)imageNames {
    
    // the filenames are stored in a plist in the app bundle, so create array by reading this plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Images" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSString *error; NSPropertyListFormat format;
    NSArray *imageNames = [NSPropertyListSerialization propertyListFromData:plistData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:&format
                                                           errorDescription:&error];
    if (!imageNames) {
        NSLog(@"Failed to read image names. Error: %@", error);
        [error release];
    }
    
    return imageNames;
}

- (void)createSlideUpViewIfNecessary {
    
    if (!slideUpView) {
        
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
        [thumbScrollView setCanCancelContentTouches:NO];
        [thumbScrollView setClipsToBounds:NO];
        
        // now place all the thumb views as subviews of the scroll view 
        // and in the course of doing so calculate the content width
        float xPosition = THUMB_H_PADDING;
        for (NSString *name in [self imageNames]) {
            UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_thumb.png", name]];
            if (thumbImage) {
                ThumbImageView *thumbView = [[ThumbImageView alloc] initWithImage:thumbImage];
                [thumbView setDelegate:self];
                [thumbView setImageName:name];
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

#pragma mark Utility methods

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
