/*
 File: RocketView.m
 Abstract: Displays the game's graphics.
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

#import "RocketView.h"

#define kFlameOffset 5.0
#define kFlameLength 8.0

@implementation RocketView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        playerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bluerocket.png"]];
        enemyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redrocket.png"]];
        [self addSubview:playerImage];
        [self addSubview:enemyImage];
        playerFrame.size = CGSizeMake(kSize,kSize*kRocketHeightRatio);
        enemyFrame.size = CGSizeMake(kSize,kSize*kRocketHeightRatio);
        ball.size = CGSizeMake(kSize,kSize);

        ballHue = 0.0;
        [self newBall];
    }
    return self;
}

- (void)dealloc {
    [ballColor release];
	[playerImage release];
	[enemyImage release];
    [super dealloc];
}

// Creates a ball of a new color to indicate a new round of play.
- (void)newBall
{
    [ballColor release];
    ballColor = [[UIColor alloc] initWithHue:ballHue saturation:0.5 brightness:1.0 alpha:1.0];
    ballHue+=0.3;
    if (ballHue > 1.0) ballHue-=1.0;
}

// Called to update the positions of objects that will be drawn on screen.
- (void)updatePlayer:(CGRect)newPlayer enemy:(CGRect)newEnemy ball:(CGRect)newBall playerThrust:(Float32) pThrust enemyThrust:(Float32) eThrust
{
    [self setNeedsDisplay];
    playerFrame = newPlayer;
    enemyFrame = newEnemy;
    ball = newBall;
    // Move the sprites to the right spot.
    playerImage.center = CGPointMake(CGRectGetMidX(playerFrame),CGRectGetMidY(playerFrame)-2.0);
    enemyImage.center = CGPointMake(CGRectGetMidX(enemyFrame),CGRectGetMidY(enemyFrame)-2.0);
    // Figure out how long the flames need to be.
    playerThrust = pThrust > 0.0 ? pThrust*kFlameLength : 0.0;
    enemyThrust = eThrust > 0.0 ? eThrust*kFlameLength : 0.0;
}

// Redraw when there has been an update.
- (void)drawRect:(CGRect)rect {
    // Blank the background.
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    UIRectFill(rect);
    // Draw the ball.
    [ballColor set];
    CGContextFillEllipseInRect(context, ball);
    // Draw the flames on the rockets.
    // The flames serve as a VU meter, showing the current loudness of each player.
    [[UIColor yellowColor] set];
    CGContextMoveToPoint(context, CGRectGetMinX(playerFrame)+kFlameOffset, CGRectGetMaxY(playerFrame));
    CGContextAddLineToPoint(context, CGRectGetMaxX(playerFrame)-kFlameOffset, CGRectGetMaxY(playerFrame));
    CGContextAddLineToPoint(context, CGRectGetMidX(playerFrame), CGRectGetMaxY(playerFrame)+playerThrust);
    CGContextFillPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(enemyFrame)+kFlameOffset, CGRectGetMaxY(enemyFrame));
    CGContextAddLineToPoint(context, CGRectGetMaxX(enemyFrame)-kFlameOffset, CGRectGetMaxY(enemyFrame));
    CGContextAddLineToPoint(context, CGRectGetMidX(enemyFrame), CGRectGetMaxY(enemyFrame)+enemyThrust);
    CGContextFillPath(context);
}

@end
