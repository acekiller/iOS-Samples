
/*
     File: ColorTileView.m
 Abstract: A custom view that draws a grid and tiles and responds to touch and shake-motion events. This class has the methods implementing copy, cut, and paste.
 
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

#import "ColorTileView.h"

NSString *ColorTileUTI = @"com.yourcompany.CopyPasteTile.colorTile";

#define Y_OFFSET 20.0
#define TILE_INSET 3.0
#define SIDE 64.0


// Private properties and methods.
@interface ColorTileView ()
@property (nonatomic, retain) NSMutableArray *tiles;
@property (nonatomic, retain) UIColor *backgroundColor;

- (CGRect)rectFromOrigin:(CGPoint)origin inset:(int)inset;
- (ColorTile *)colorTileForOrigin:(CGPoint)curOrigin;
@end


@implementation ColorTileView


@synthesize tiles, backgroundColor;


#pragma mark -
#pragma mark Configuration

- (void)awakeFromNib {
	
	self.backgroundColor = [UIColor colorWithRed:255.0 green:235.0 blue:180.0 alpha:0.8];
	self.tiles = [NSMutableArray arrayWithCapacity:120];
	currentSelection = CGPointMake(-0.1, -0.1);		
	[self resetBoard];
	[self becomeFirstResponder];
}


// Touch handling, tile selection, and menu/pasteboard.
- (BOOL)canBecomeFirstResponder {
	return YES;
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
	
    // Draw the board
	if (redrawBoard) {
		
		[backgroundColor set];
		UIRectFill(rect);
		UIColor *lineColor = [UIColor darkGrayColor];
		[lineColor set];
		
		float x = 0.0, y = 20.0;
		for (float w = 0; w < 6; w++) {
			CGRect line = CGRectMake(x, y, 1.0, 384.0);
			UIRectFrame(line);
			x += SIDE;
		}
		
		x = 0.0, y = 20.0;
		for (float h = 0; h < 7; h++) {
			CGRect line = CGRectMake(x, y, 320.0, 1.0);
			UIRectFrame(line);
			y += SIDE;
		}
		
		for (ColorTile *tile in tiles) {
			CGRect tileRect = [self rectFromOrigin:tile.tileOrigin inset:TILE_INSET];
			[tile.tileColor set];
			UIRectFill(tileRect);
		}
		
		redrawBoard = NO;
		return;
	}
	
	// Draw the current selection (tile or empty square).
	CGRect tileRect = [self rectFromOrigin:currentSelection inset:TILE_INSET];
	ColorTile *theTile = [self colorTileForOrigin:CGPointMake(currentSelection.x, currentSelection.y)];
	if (!theTile) {
		// No tile for square, draw gray background. 
		[backgroundColor set];
		UIRectFill(tileRect);
		
	}
	else { 
		// Draw with color of tile as fill.
		[theTile.tileColor set];
		UIRectFill(tileRect);
	}
}


#pragma mark -
#pragma mark Resetting the board

- (IBAction)resetBoard {
	
	/*
	 Remove all existing tiles and create an initial set of four tiles with different colors.
	 */
	[tiles removeAllObjects];

	ColorTile *gTile = [[ColorTile alloc] init];
	gTile.tileOrigin = CGPointMake(0.0, 0.0+Y_OFFSET);
	gTile.tileColor = [UIColor greenColor];
	[tiles addObject:gTile];
	
	ColorTile *blTile = [[ColorTile alloc] init];
	blTile.tileOrigin = CGPointMake(128.0, 128.0+Y_OFFSET);
	blTile.tileColor = [UIColor blueColor];
	[tiles addObject:blTile];
	
	ColorTile *rTile = [[ColorTile alloc] init];
	rTile.tileOrigin = CGPointMake(192.0, 192.0+Y_OFFSET);
	rTile.tileColor = [UIColor redColor];
	[tiles addObject:rTile];
	
	ColorTile *brTile = [[ColorTile alloc] init];
	brTile.tileOrigin = CGPointMake(256.0, 256.0+Y_OFFSET);
	brTile.tileColor = [UIColor brownColor];
	[tiles addObject:brTile];
	
	[gTile release];
	[blTile release];
	[rTile release];
	[brTile release];
	
	redrawBoard = YES;
	[self setNeedsDisplay];
}


#pragma mark -
#pragma mark Motion-event handling

/*
 Custom views should implement all motion-event handlers, even if it's a null implementation, and not call super.
 */

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	
}


// Shaking resets board.
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion = UIEventSubtypeMotionShake ) {
		[self resetBoard];
	}
}


- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	
}



#pragma mark -
#pragma mark Touch handling

/*
 Custom views should implement all touch handlers, even if it's a null implementation, and should not call super.
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *theTouch = [touches anyObject];
		
	/*
	 If this is a double tap, then try to display the menu.
	 The call to becomeFirstResponder is required for the editing menu to appear.
	 */
	if (([theTouch tapCount] == 2) && [self becomeFirstResponder]) {
		
		CGPoint tapPoint = [theTouch locationInView:self];
		// Reject taps below grid.
		if (tapPoint.y > (SIDE * 6) + Y_OFFSET) {
			return;
		}
		
		long int tempX = lround(tapPoint.x);
		long int tempY = lround(tapPoint.y-Y_OFFSET);
		long int aSide = (long int)SIDE;
		long int origxoffset = tempX%aSide;
		long int origyoffset = tempY%aSide;
		
		tapPoint.x = (double)tempX - origxoffset;
		tapPoint.y = (double)(tempY+Y_OFFSET) - origyoffset;

		currentSelection = tapPoint;
		
		CGRect drawRect = [self rectFromOrigin:currentSelection inset:TILE_INSET];
		[self setNeedsDisplayInRect:drawRect];
        
		/*
		 Get the shared UIMenuController instance, find the area the menu
		 should point at, and animate the menu onto the view
		 */
		UIMenuController *theMenu = [UIMenuController sharedMenuController];
		[theMenu setTargetRect:drawRect inView:self];
		[theMenu setMenuVisible:YES animated:YES];
		
		return;
	}
	
	/*
	 If this is a single tap, and the menu is visible, hide it.
	 */
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	
	if ([theTouch tapCount] == 1  && [menuController isMenuVisible]) {
		[menuController setMenuVisible:NO animated:YES];
	}
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}


#pragma mark -
#pragma mark Menu commands and validation

/*
 The view implements this method to conditionally enable or disable commands of the editing menu. 
 The canPerformAction:withSender method is declared by UIResponder.
 */

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL retValue = NO;
	ColorTile *theTile = [self colorTileForOrigin:currentSelection];
	
	if (action == @selector(paste:)) {
		// The square must have no tile and there must be a ColorTile object in the pasteboard.
		retValue = (theTile == nil) && [[UIPasteboard generalPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:ColorTileUTI]];
	}
    else {
		if (action == @selector(cut:) || action == @selector(copy:)) {
			// The square must hold a ColorTile object.
			retValue = (theTile != nil);
		}
		else {
			// Pass the canPerformAction:withSender: message to the superclass
			// and possibly up the responder chain.
			retValue = [super canPerformAction:action withSender:sender];
		}
	}
    return retValue;
}


/*
 These methods are declared by the UIResponderStandardEditActions informal protocol.
 */
- (void)copy:(id)sender {
	
	// Get the General pasteboard and the current tile.
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	ColorTile *theTile = [self colorTileForOrigin:currentSelection];
	
	if (theTile) {
		// Create an archive of the ColorTile object as an NSData object.
		NSData *tileData = [NSKeyedArchiver archivedDataWithRootObject:theTile];
		if (tileData)
			// Write the archived data to the pasteboard.
			[gpBoard setData:tileData forPasteboardType:ColorTileUTI];
	}
}


- (void)cut:(id)sender {
	
	// Get the current tile, if there is one.
	ColorTile *theTile = [self colorTileForOrigin:currentSelection];
	if (theTile) {

		// Invoke copy: to write tile to pasteboard.
		[self copy:sender];
		
		// Remove the ColorTile object from data model and from display.
		CGPoint tilePoint = theTile.tileOrigin;
		[tiles removeObject:theTile];
		CGRect tileRect = [self rectFromOrigin:tilePoint inset:TILE_INSET];
		[self setNeedsDisplayInRect:tileRect];
	}
}


- (void)paste:(id)sender {
	
	// Get the General pasteboard, the current tile, and create an array
	// containing the color tile UTI.
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	ColorTile *theTile = [self colorTileForOrigin:currentSelection];
	NSArray *pbType = [NSArray arrayWithObject:ColorTileUTI];
	
	// If there is no tile and the item on the pasteboard is the correct type...
	if ((theTile == nil) && [gpBoard containsPasteboardTypes:pbType]) {
		
		// ... read the ColorTile object from the pasteboard.
		NSData *tileData = [gpBoard dataForPasteboardType:ColorTileUTI];
		ColorTile *theTile = (ColorTile *)[NSKeyedUnarchiver unarchiveObjectWithData:tileData];
		
		// Add the ColorTile object to the data model and update the display.
		if (theTile) {
			theTile.tileOrigin = currentSelection;
			[tiles addObject:theTile];
			CGRect tileRect = [self rectFromOrigin:currentSelection inset:TILE_INSET];
			[self setNeedsDisplayInRect:tileRect];
		} 
	}
}


#pragma mark -
#pragma mark Utility methods

- (CGRect)rectFromOrigin:(CGPoint)origin inset:(int)inset {
	CGRect newRect = CGRectMake(origin.x+inset, origin.y+inset, SIDE-inset-1.0, SIDE-inset-1.0);
	return newRect;
}

- (ColorTile *)colorTileForOrigin:(CGPoint)curOrigin {
	for (ColorTile *tile in tiles) {
		if (CGPointEqualToPoint(tile.tileOrigin, curOrigin)) {
			return tile;
		}
	}
	return nil;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[tiles release];
	[backgroundColor release];
	[super dealloc];
}


@end
