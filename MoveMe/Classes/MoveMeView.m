
/*
     File: MoveMeView.m
 Abstract: Contains a (placard) view that can be moved by touch. Illustrates
 handling touch events and two styles of animation.
 
  Version: 2.7
 
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

#import "MoveMeView.h"
#import "PlacardView.h"
// Import QuartzCore for animations
#import <QuartzCore/QuartzCore.h>


@implementation MoveMeView

@synthesize placardView;


/*
 If the view is stored in the nib file, when it's unarchived it's sent -initWithCoder:.
 This is the case in the example as provided.  See also initWithFrame:.
*/
- (id)initWithCoder:(NSCoder *)coder {
	
	if (self = [super initWithCoder:coder]) {
		[self setUpPlacardView];
	}
	return self;
}

/*
 If you were to create the view programmatically, you would use initWithFrame:.
 You want to make sure the placard view is set up in this case as well (as in initWithCoder:).
 */
- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		[self setUpPlacardView];
	}
	return self;
}


- (void)setUpPlacardView {
	// Create the placard view -- its init method calculates its frame based on its image
	PlacardView *aPlacardView = [[PlacardView alloc] init];
	self.placardView = aPlacardView;
	[aPlacardView release];
	placardView.center = self.center;
	[self addSubview:placardView];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [touches anyObject];
	
	// Only move the placard view if the touch was in the placard view
	if ([touch view] != placardView) {
		// In case of a double tap outside the placard view, update the placard's display string
		if ([touch tapCount] == 2) {
			[placardView setupNextDisplayString];
		}
		return;
	}
	// Animate the first touch
	CGPoint touchPoint = [touch locationInView:self];
	[self animateFirstTouchAtPoint:touchPoint];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	
	// If the touch was in the placardView, move the placardView to its location
	if ([touch view] == placardView) {
		CGPoint location = [touch locationInView:self];
		placardView.center = location;		
		return;
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	
	// If the touch was in the placardView, bounce it back to the center
	if ([touch view] == placardView) {
		// Disable user interaction so subsequent touches don't interfere with animation
		self.userInteractionEnabled = NO;
		[self animatePlacardViewToCenter];
		return;
	}		
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	/*
     To impose as little impact on the device as possible, simply set the placard view's center and transformation to the original values.
     */
	placardView.center = self.center;
	placardView.transform = CGAffineTransformIdentity;
}


/*
 First of two possible implementations of animateFirstTouchAtPoint: illustrating different behaviors.
 To choose the second, replace '1' with '0' below.
 */

#if 1

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {
	/*
	 "Pulse" the placard view by scaling up then down, then move the placard to under the finger.
	 
	 This illustrates using UIView's built-in animation.  We want, though, to animate the same property (transform) twice -- first to scale up, then to shrink.  You can't animate the same property more than once using the built-in animation -- the last one wins.  So we'll set a delegate action to be invoked after the first animation has finished.  It will complete the sequence.
	 Note that we can pass information -- in this case, the using the context.  The context needs to be a pointer. A convenient way to pass a CGPoint here is to wrap it in an NSValue object.  However, the value returned from valueWithCGPoint is autoreleased.  Normally this wouldn't be an issue because typically if you need to use the value later you store it as an instance variable using an accessor method that retains it, or pass it to another object which retains it.  In this case, though, it's being passed as a void * parameter, and it's not retained by the UIView class.  By the time the delegate method is called, therefore, the autorelease pool will have been popped and the value would no longer be valid.  To address this problem, retain the value here, and release it in the delegate method.
	 */
	
#define GROW_ANIMATION_DURATION_SECONDS 0.15
	
	NSValue *touchPointValue = [[NSValue valueWithCGPoint:touchPoint] retain];
	[UIView beginAnimations:nil context:touchPointValue];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
	placardView.transform = transform;
	[UIView commitAnimations];
}


- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
#define MOVE_ANIMATION_DURATION_SECONDS 0.15
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
	placardView.transform = CGAffineTransformMakeScale(1.1, 1.1);	
	/*
	 Move the placardView to under the touch.
	 We passed the location wrapped in an NSValue as the context.
	 Get the point from the value, then release the value because we retained it in touchesBegan:withEvent:.
	 */
	NSValue *touchPointValue = (NSValue *)context;
	placardView.center = [touchPointValue CGPointValue];
	[touchPointValue release];
	[UIView commitAnimations];
}


#else

/*
 Alternate behavior.
 The preceding implementation grows the placard in place then moves it to the new location and shrinks it at the same time.  An alternative is to move the placard for the total duration of the grow and shrink operations; this gives a smoother effect.
 
 */

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {
	
#define GROW_ANIMATION_DURATION_SECONDS 0.15
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15
	
	/*
	 Create two separate animations, the first for the grow, which uses a delegate method as before to start an animation for the shrink operation. The second animation here lasts for the total duration of the grow and shrink animations and is responsible for performing the move.
	 */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
	placardView.transform = transform;
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS + SHRINK_ANIMATION_DURATION_SECONDS];
	placardView.center = touchPoint;
	[UIView commitAnimations];
}


- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:SHRINK_ANIMATION_DURATION_SECONDS];
	placardView.transform = CGAffineTransformMakeScale(1.1, 1.1);	
	[UIView commitAnimations];
}


#endif


- (void)animatePlacardViewToCenter {
	
	// Bounces the placard back to the center
		
	CALayer *welcomeLayer = placardView.layer;
	
	// Create a keyframe animation to follow a path back to the center
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
	
	CGFloat animationDuration = 1.5;

	
	// Create the path for the bounces
	CGMutablePathRef thePath = CGPathCreateMutable();
	
	CGFloat midX = self.center.x;
	CGFloat midY = self.center.y;
	CGFloat originalOffsetX = placardView.center.x - midX;
	CGFloat originalOffsetY = placardView.center.y - midY;
	CGFloat offsetDivider = 4.0;
	
	BOOL stopBouncing = NO;
	
	// Start the path at the placard's current location
	CGPathMoveToPoint(thePath, NULL, placardView.center.x, placardView.center.y);
	CGPathAddLineToPoint(thePath, NULL, midX, midY);
	
	// Add to the bounce path in decreasing excursions from the center
	while (stopBouncing != YES) {
		CGPathAddLineToPoint(thePath, NULL, midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
		CGPathAddLineToPoint(thePath, NULL, midX, midY);

		offsetDivider += 4;
		animationDuration += 1/offsetDivider;
		if ((abs(originalOffsetX/offsetDivider) < 6) && (abs(originalOffsetY/offsetDivider) < 6)) {
			stopBouncing = YES;
		}
	}
	
	bounceAnimation.path = thePath;
	bounceAnimation.duration = animationDuration;
	CGPathRelease(thePath);
	
	// Create a basic animation to restore the size of the placard
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
	transformAnimation.duration = animationDuration;
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	
	
	// Create an animation group to combine the keyframe and basic animations
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	theGroup.animations = [NSArray arrayWithObjects:bounceAnimation, transformAnimation, nil];
	
	
	// Add the animation group to the layer
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
	
	// Set the placard view's center and transformation to the original values in preparation for the end of the animation
	placardView.center = self.center;
	placardView.transform = CGAffineTransformIdentity;
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	//Animation delegate method called when the animation's finished:
	// restore the transform and reenable user interaction
	placardView.transform = CGAffineTransformIdentity;
	self.userInteractionEnabled = YES;
}


- (void)dealloc {
	[placardView release];
	[super dealloc];	
}

@end
