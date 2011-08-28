/*
 File: RocketController.m
 Abstract: Controls the logic, controls, networking, and view of the actual game.
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

#import "RocketController.h"
#import <GameKit/GKVoiceChatService.h>

#define kGravity 2.0
#define kRestitution 0.99
#define kBallSpeed 4.0
#define kMaxV 35.0
#define kMinV 18.0
#define kWorldX 320.0
#define kWorldY 320.0
#define kBorder 10.0
#define kStartY kWorldY/3.0
#define kOffscreen 3.0
#define kThrustOffset 60.0
#define kThrustRatio 12.0
#define kTimestep 0.033
#define randomV() -2.0+4.0*(Float32)random()/(Float32)RAND_MAX

typedef struct {
    CFSwappedFloat32 playerY;
    CFSwappedFloat32 playerV;
    CFSwappedFloat32 ballY;
    CFSwappedFloat32 ballV;
} Packet;

@implementation RocketController
@synthesize stateLabel;
@synthesize playerScoreLabel;
@synthesize enemyScoreLabel;
@synthesize touchLabel;

#pragma mark View Controller Methods

 /* The designated initializer.  Override if you create the controller
    programmatically and want to perform customization that is not appropriate
    for viewDidLoad. */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil manager:(SessionManager *)aManager
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        manager = [aManager retain];
        manager.gameDelegate = self;
        srandomdev();
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [manager displayNameForPeer:manager.currentConfPeerID];

    UIBarButtonItem *endButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"End Game"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(endButtonHit)];
    self.navigationItem.leftBarButtonItem = endButton;
    [endButton release];
    
    self.navigationItem.hidesBackButton = YES;
    
    stateLabel.text = @"Connecting...";
    
    rocketStart = FALSE;
    playerTalking = FALSE;
    enemyTalking = FALSE;
    playerScore = 0;
    enemyScore = 0;
    
    // Create the game graphics view
    CGRect	rect = CGRectMake(0.0, 0.0, kWorldX, kWorldY); 
    rocketView = [[RocketView alloc] initWithFrame:rect];
    [self.view addSubview:rocketView];
    
    player.bounds.size = CGSizeMake(kSize,kSize*kRocketHeightRatio);
    enemy.bounds.size = CGSizeMake(kSize,kSize*kRocketHeightRatio);
    ball.bounds.size = CGSizeMake(kSize,kSize);
    [self resetRockets:FALSE initialVelocity:0.0];
    [rocketView updatePlayer:player.bounds enemy:enemy.bounds ball:ball.bounds
                playerThrust:player.thrust enemyThrust:enemy.thrust];
}

- (void)viewDidUnload
{
    self.stateLabel = nil;
    self.playerScoreLabel = nil;
    self.enemyScoreLabel = nil;
    self.touchLabel = nil;
    [rocketView release];
    rocketView = nil;
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc 
{
    [rocketView release];
	rocketView = nil;
    manager.gameDelegate = nil;
	[manager release];
    manager = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Connection and Timer Logic

// Update the call timer once a second.
- (void) updateElapsedTime:(NSTimer *) timer
{
	int hour, minute, second;
	NSTimeInterval elapsedTime = [NSDate timeIntervalSinceReferenceDate] - startTime;
	hour = elapsedTime / 3600;
	minute = (elapsedTime - hour * 3600) / 60;
	second = (elapsedTime - hour * 3600 - minute * 60);
	callTimerLabel.text = [NSString stringWithFormat:@"%2d:%02d:%02d", hour, minute, second];
}

// Called when the user hits the end call toolbar button.
-(void) endButtonHit
{
    [manager disconnectCurrentCall];
}

#pragma mark -
#pragma mark SessionManagerGameDelegate Methods

- (void) voiceChatWillStart:(SessionManager *)session
{
    stateLabel.text = @"Starting Voice Chat";
}

- (void) session:(SessionManager *)session didConnectAsInitiator:(BOOL)shouldStart
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
    stateLabel.text = @"Connected"; 
    
    // Schedule the game to update at 30fps and the call timer at 1fps.
	if (nil == callTimer) {
		callTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                    selector:@selector(updateElapsedTime:) userInfo:nil repeats:YES] retain];
        rocketTimer = [[NSTimer scheduledTimerWithTimeInterval:kTimestep target:self
                                                      selector:@selector(updateRockets:) userInfo:nil repeats:YES] retain];
        startTime = [NSDate timeIntervalSinceReferenceDate];
        
        // If the user is starting the voice chat, let the other player be the one
        // who starts the game.  That way both players are starting at the same time.
        if (shouldStart) {
            [self resetRockets:TRUE initialVelocity:randomV()];
            [self sendPacket:PacketTypeStart];
            rocketStart = TRUE;
        }
	}
}

// If hit end call or the call failed or timed out, clear the state and go back a screen.
- (void) willDisconnect:(SessionManager *)session
{
    stateLabel.text = @"Disconnected";
    rocketStart = FALSE;
    playerTalking = FALSE;
    enemyTalking = FALSE;
    
    [callTimer invalidate];
    [rocketTimer invalidate];
	[callTimer release];
	[rocketTimer release];
	callTimer = nil;
	rocketTimer = nil;
    
	[rocketView release];
	rocketView = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[self.navigationController popViewControllerAnimated:YES];
    
   	manager.gameDelegate = nil;
	[manager release];
    manager = nil;
}

// The GKSession got a packet and sent it to the game, so parse it and update state.
- (void) session:(SessionManager *)session didReceivePacket:(NSData*)data ofType:(PacketType)packetType
{
    Packet incoming;
    if ([data length] == sizeof(Packet)) {
        [data getBytes:&incoming length:sizeof(Packet)];
        
        switch (packetType) {
            case PacketTypeStart:
                // The other player started the game, so unpause our graphics
                // and set the initial ball velocity.
                rocketStart = TRUE;
                [self resetRockets:FALSE initialVelocity:CFConvertFloat32SwappedToHost(incoming.ballV)];
                break;
            case PacketTypeBounce:
                // The other player hit the ball back towards us.
                enemy.bounds.origin.y = CFConvertFloat32SwappedToHost(incoming.playerY);
                enemy.velocity = CFConvertFloat32SwappedToHost(incoming.playerV);
                ball.velocity.y = CFConvertFloat32SwappedToHost(incoming.ballV);
                ball.velocity.x = -kBallSpeed;
                ball.bounds.origin.y = CFConvertFloat32SwappedToHost(incoming.ballY);
                ball.bounds.origin.x = kWorldX-kSize*2.0-kBorder;
                break;
            case PacketTypeScore:
                // The other player missed, we scored, and the ball is being served
                // towards us.
                [self resetRockets:FALSE initialVelocity:CFConvertFloat32SwappedToHost(incoming.ballV)];
                playerScore++;
                playerScoreLabel.text = [NSString stringWithFormat:@"%u",(unsigned int)playerScore];
                break;
            case PacketTypeTalking:
                // The other player is speaking and doesn't want to thrust.
                enemyTalking = YES;
                enemy.thrust = 0.0;
                break;
            case PacketTypeEndTalking:
                // The other player is ready to play again.
                enemyTalking = NO;
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark Game Network Logic

// Send the same information each time, just with a different header
-(void) sendPacket:(PacketType)packetType
{
    Packet outgoing;
    outgoing.playerY = CFConvertFloat32HostToSwapped(player.bounds.origin.y);
    outgoing.playerV = CFConvertFloat32HostToSwapped(player.velocity);
    outgoing.ballY = CFConvertFloat32HostToSwapped(ball.bounds.origin.y);
    outgoing.ballV = CFConvertFloat32HostToSwapped(ball.velocity.y);
    NSData *packet = [[NSData alloc] initWithBytes:&outgoing length:sizeof(Packet)];
    [manager sendPacket:packet ofType:packetType];
    [packet release];
}



#pragma mark Game Control and Graphics Logic

// The bulk of the game logic. moves objects around and sends packets if necessary.
-(void) updateRockets:(NSTimer*)timer
{
    // If the game hasn't started, the graphics will just be stationary.
    if (rocketStart) {
        // Allow for frameskipping in case a timer is delayed.
        NSTimeInterval tempTimestamp = [NSDate timeIntervalSinceReferenceDate];
        int timesteps = (int)((tempTimestamp-frameskipTimestamp)/kTimestep);
        frameskipTimestamp = tempTimestamp;
        timesteps = ((timesteps < 1) ? 1 : timesteps);
        while (timesteps--) {
            // Apply acceleration to velocity and velocity to position.
            [self moveRockets];
            [self moveBall];
            
            // Check if the rockets or ball are hitting the ceiling or floor.
            [self collideRocketsWithWorld];
            [self collideBallWithWorld];
            
            // Check if the ball hit a rocket or scored.
            [self checkScoring];
        }
        
        // Tell the graphics to update.
        [rocketView updatePlayer:player.bounds enemy:enemy.bounds ball:ball.bounds
                    playerThrust:player.thrust enemyThrust:enemy.thrust];
    }
}

// Apply acceleration to velocity and velocity to position.
-(void) moveRockets
{
    player.velocity += kGravity;
    enemy.velocity += kGravity;
    // Add the acceleration of the voice thrust to the rockets if the player
    // is not touching the screen.
    if (!playerTalking) {
        float level = [[GKVoiceChatService defaultVoiceChatService] inputMeterLevel];
        // The decibel level may be 0.0 if there is no audio
        // otherwise its a negative number, with closer to 0.0 being louder
        player.thrust = (level == 0.0) ? 0.0 : (level+kThrustOffset)/kThrustRatio;
        player.velocity -= player.thrust;
    }
    if (!enemyTalking) {
        float level = [[GKVoiceChatService defaultVoiceChatService] outputMeterLevel];
        enemy.thrust = (level == 0.0) ? 0.0 : (level+kThrustOffset)/kThrustRatio;
        enemy.velocity -= enemy.thrust;
    }
    // clamp the rocket speeds.
    player.velocity = player.velocity > kMaxV ? kMaxV : (player.velocity < -kMaxV ? -kMaxV : player.velocity);
    enemy.velocity = enemy.velocity > kMaxV ? kMaxV : (enemy.velocity < -kMaxV ? -kMaxV : enemy.velocity);
    
    // Apply a time step of velocity to the object positions
    player.bounds.origin.y += player.velocity;
    enemy.bounds.origin.y += enemy.velocity;
}

// Apply acceleration to velocity and velocity to position.
-(void) moveBall
{
    ball.velocity.y += kGravity;
    // clamp the ball's velocity to keep the game playable.
    ball.velocity.y = ((ball.velocity.y > kMaxV) ? kMaxV : ((ball.velocity.y < -kMaxV) ? -kMaxV : ball.velocity.y));
    ball.bounds.origin.y += ball.velocity.y;
    ball.bounds.origin.x += ball.velocity.x;
}

// Check if the rockets are hitting the ceiling or floor.
-(void) collideRocketsWithWorld
{
    // Keep the objects from shooting off the top or bottom of the screen.
    if (player.bounds.origin.y < 0.0) {
        player.bounds.origin.y = 0.0;
        player.velocity = 0.0;
    } else if (player.bounds.origin.y > kWorldY-kSize*kRocketHeightRatio) {
        player.bounds.origin.y = kWorldX-kSize*kRocketHeightRatio;
        player.velocity = 0.0;
    }
    if (enemy.bounds.origin.y < 0.0) {
        enemy.bounds.origin.y = 0.0;
        enemy.velocity = 0.0;
    } else if (enemy.bounds.origin.y > kWorldY-kSize*kRocketHeightRatio) {
        enemy.bounds.origin.y = kWorldX-kSize*kRocketHeightRatio;
        enemy.velocity = 0.0;
    }
}

// Check if the ball is hitting the ceiling or floor.
-(void) collideBallWithWorld
{
    // Note that the ball loses a little energy with every bounce.
    if (ball.bounds.origin.y < 0.0) {
        ball.velocity.y = -ball.velocity.y*kRestitution;
    } else if (ball.bounds.origin.y > kWorldY-kSize) {
        ball.bounds.origin.y = kWorldY-kSize;
        ball.velocity.y = -ball.velocity.y*kRestitution;
        // Make sure there is some bounce, and it isn't just rolling.
        ball.velocity.y = ball.velocity.y > -kMinV ? -kMinV : ball.velocity.y;
    }
}

// Check if the ball hit a rocket or scored.
-(void) checkScoring
{
    // In range to check for collision or scoring.
    if (ball.bounds.origin.x < kSize+kBorder) {
        // If there is collision, send the bounce packet.
        if (CGRectIntersectsRect(player.bounds, ball.bounds)) {
            ball.velocity.x = kBallSpeed;
            ball.velocity.y += player.velocity;
            ball.bounds.origin.x = kSize+kBorder;
            [self sendPacket:PacketTypeBounce];
            // If the ball goes far enough, its a goal, reset and send a 
            // score packet.
        } else if (ball.bounds.origin.x < kBorder+kSize/2.0) {
            [self resetRockets:TRUE initialVelocity:randomV()];
            [self sendPacket:PacketTypeScore];
            enemyScore++;
            enemyScoreLabel.text = [NSString stringWithFormat:@"%d",enemyScore];
        }
    } else if (ball.bounds.origin.x > kWorldX*kOffscreen) {
        // If the ball gets way off screen, it means we stopped getting
        // packets due to a network problem, so disconnect.
        [manager disconnectCurrentCall];
    }
}

// Set the rockets and the ball to an initial position.
-(void) resetRockets:(BOOL)serve initialVelocity:(Float32)vel
{
    [rocketView newBall];
    
    player.bounds.origin = CGPointMake(kBorder,kWorldY-kRocketHeightRatio*kSize);
    player.velocity = 0.0;
    player.thrust = 0.0;
    enemy.bounds.origin = CGPointMake(kWorldX-kBorder-kSize,kWorldY-kRocketHeightRatio*kSize);
    enemy.velocity = 0.0;
    enemy.thrust = 0.0;
    if (serve) {
        ball.bounds.origin = CGPointMake(kSize+kBorder,kStartY);
        ball.velocity = CGPointMake(kBallSpeed,vel);
    } else {
        ball.bounds.origin = CGPointMake(kWorldX-2.0*kSize-kBorder,kStartY);
        ball.velocity = CGPointMake(-kBallSpeed,vel);
    }
    
    frameskipTimestamp = [NSDate timeIntervalSinceReferenceDate];
}

// Stop thrusting the rocket when the user touches the screen, allowing them
// to talk without making the game impossible to play.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    playerTalking = YES;
    player.thrust = 0.0;
    touchLabel.text = @"Untouch screen to resume rocketing.";
    [self sendPacket:PacketTypeTalking];
}

// Resume thrusting the rocket.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    playerTalking = NO;
    touchLabel.text = @"Touch screen to speak without rocketing.";
    [self sendPacket:PacketTypeEndTalking];
}

// Same as touchesEnded.
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end
