
/*
     File: ThumbImageView.m
 Abstract: UIImageView subclass to display a thumbnail image; notifies a delegate of various interactions.
 
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

#import "ThumbImageView.h"

#define DRAG_THRESHOLD 10

float distanceBetweenPoints(CGPoint a, CGPoint b);

@implementation ThumbImageView
@synthesize delegate;
@synthesize imageName;
@synthesize home;
@synthesize touchLocation;

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];  // block other touches while dragging a thumb view
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // store the location of the starting touch so we can decide when we've moved far enough to drag
    touchLocation = [[touches anyObject] locationInView:self];
    if ([delegate respondsToSelector:@selector(thumbImageViewStartedTracking:)])
        [delegate thumbImageViewStartedTracking:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // we want to establish a minimum distance that the touch has to move before it counts as dragging,
    // so that the slight movement involved in a tap doesn't cause the frame to move.
    
    CGPoint newTouchLocation = [[touches anyObject] locationInView:self];
    
    // if we're already dragging, move our frame
    if (dragging) {
        float deltaX = newTouchLocation.x - touchLocation.x;
        float deltaY = newTouchLocation.y - touchLocation.y;
        [self moveByOffset:CGPointMake(deltaX, deltaY)];
    }
    
    // if we're not dragging yet, check if we've moved far enough from the initial point to start
    else if (distanceBetweenPoints(touchLocation, newTouchLocation) > DRAG_THRESHOLD) {
        touchLocation = newTouchLocation;
        dragging = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (dragging) {
        [self goHome];
        dragging = NO;
    } else if ([[touches anyObject] tapCount] == 1) {
        if ([delegate respondsToSelector:@selector(thumbImageViewWasTapped:)])
            [delegate thumbImageViewWasTapped:self];
    }
    
    if ([delegate respondsToSelector:@selector(thumbImageViewStoppedTracking:)]) 
        [delegate thumbImageViewStoppedTracking:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self goHome];
    dragging = NO;
    if ([delegate respondsToSelector:@selector(thumbImageViewStoppedTracking:)]) 
        [delegate thumbImageViewStoppedTracking:self];
}

- (void)goHome {
    // distance is in pixels
    float distanceFromHome = distanceBetweenPoints([self frame].origin, [self home].origin);  
    // duration is in seconds, so each additional pixel adds only 1/1000th of a second.
    float animationDuration = 0.1 + distanceFromHome * 0.001; 
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self setFrame:[self home]];
    [UIView commitAnimations];
}
    
- (void)moveByOffset:(CGPoint)offset {
    CGRect frame = [self frame];
    frame.origin.x += offset.x;
    frame.origin.y += offset.y;
    [self setFrame:frame];
    if ([delegate respondsToSelector:@selector(thumbImageViewMoved:)])
        [delegate thumbImageViewMoved:self];
}    

@end

float distanceBetweenPoints(CGPoint a, CGPoint b) {
    float deltaX = a.x - b.x;
    float deltaY = a.y - b.y;
    return sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
}
            
