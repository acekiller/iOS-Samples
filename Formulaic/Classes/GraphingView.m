/*
 
 File: GraphingView.m
 
 Abstract: Graphing view
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
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

#import "GraphingView.h"
#import "ViewController.h"

@implementation GraphingView

@synthesize formulaConstant;

- (void)dealloc
{
    [accessibilityChildren release];
    [super dealloc];
}

#pragma mark -
#pragma mark === Accessibility Container methods ===

// _accessibilityChildren returns the list of "sub-elements" that GraphingView contains
- (NSArray *)_accessibilityChildren
{
    if ( accessibilityChildren != nil )
    {
        return accessibilityChildren;
    }
    
    accessibilityChildren = [[NSMutableArray alloc] init];

    // create an accessibility element to represent the graph
    UIAccessibilityElement *graph = [[[UIAccessibilityElement alloc] initWithAccessibilityContainer:self] autorelease];
    graph.accessibilityLabel = @"Graph";
    graph.accessibilityTraits = UIAccessibilityTraitImage;
    [accessibilityChildren addObject:graph];
    
    // create accessibility elements for each "button"
    // assign labels and traits
    // add to the children array
    
    UIAccessibilityElement *button1 = [[[UIAccessibilityElement alloc] initWithAccessibilityContainer:self] autorelease];
    button1.accessibilityLabel = @"f of negative pi over 2";
    button1.accessibilityTraits = UIAccessibilityTraitButton;
    [accessibilityChildren addObject:button1];
    
    UIAccessibilityElement *button2 = [[[UIAccessibilityElement alloc] initWithAccessibilityContainer:self] autorelease];
    button2.accessibilityLabel = @"f of 0";
    button2.accessibilityTraits = UIAccessibilityTraitButton;
    [accessibilityChildren addObject:button2];
    
    UIAccessibilityElement *button3 = [[[UIAccessibilityElement alloc] initWithAccessibilityContainer:self] autorelease];
    button3.accessibilityLabel = @"f of pi over 2";
    button3.accessibilityTraits = UIAccessibilityTraitButton;
    [accessibilityChildren addObject:button3];

    // set the frame of each method. 
    // use this view's accessibilityFrame to base calculations off of
    
    CGRect frame = [self accessibilityFrame];
    CGFloat height = 40, width = 60;
    
    button1.accessibilityFrame = CGRectMake(frame.origin.x + 15, CGRectGetMaxY(frame) - height, width, height); 
    button2.accessibilityFrame = CGRectMake(frame.origin.x + 105, CGRectGetMaxY(frame) - height, width, height); 
    button3.accessibilityFrame = CGRectMake(frame.origin.x + 190, CGRectGetMaxY(frame) - height, width, height);     
    graph.accessibilityFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - height);   
    
    return accessibilityChildren;
}

// if a UIView implements the container protocol, it cannot be an accessible element
- (BOOL)isAccessibilityElement
{
    return NO;
}

// Accessibility Container protocol methods only need to reference _accessibilityChildren to be complete
- (NSInteger)accessibilityElementCount
{
    return [[self _accessibilityChildren] count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    return [[self _accessibilityChildren] objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return [[self _accessibilityChildren] indexOfObject:element];    
}

#pragma mark -
#pragma mark === Drawing and layout methods ===

- (void)awakeFromNib
{
    // set up a rounded border
    CALayer *layer = [self layer];

    // clear the view's background color so that our background
    // fits within the rounded border
    CGColorRef backgroundColor = [self.backgroundColor CGColor];
    self.backgroundColor = [UIColor clearColor];
    layer.backgroundColor = backgroundColor;

    layer.borderColor = [[UIColor blackColor] CGColor];
    layer.borderWidth = 3.0f;
    layer.cornerRadius = 4.0f;
    
    shapeLayer = [CAShapeLayer layer];   
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [shapeLayer setLineCap:kCALineCapRound];
    [shapeLayer setLineWidth:4.0f];
    [layer addSublayer:shapeLayer];   
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // draw the "buttons" which are really strings.
    [[UIColor whiteColor] set];
    [[NSString stringWithString:@"f(-∏/2)"] drawAtPoint:CGPointMake(CGRectGetMinX(rect) + 20, CGRectGetMaxY(rect) - 30) withFont:[UIFont boldSystemFontOfSize:16]];
    [[NSString stringWithFormat:@"f(0.00)"] drawAtPoint:CGPointMake(CGRectGetMinX(rect) + 110, CGRectGetMaxY(rect) - 30) withFont:[UIFont boldSystemFontOfSize:16]];
    [[NSString stringWithString:@"f(∏/2)"] drawAtPoint:CGPointMake(CGRectGetMinX(rect) + 200, CGRectGetMaxY(rect) - 30) withFont:[UIFont boldSystemFontOfSize:16]];    
}

- (void)updateGraph
{
    // draw the graph line
    CGRect bounds = self.bounds;
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat startX = CGRectGetMinX(bounds) + 10;
    CGFloat width = CGRectGetWidth(bounds) - 20;
    
    CGFloat startY = CGRectGetMidY(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    
    CGPathMoveToPoint(path, NULL, startX, startY);
    CGFloat x;
    for ( x = -2*M_PI; x <= 2*M_PI; x += .15 )
    {
        // find the value that we will plot
        CGFloat fx = formulaConstant * x * sin(x);
        
        // convert the x value to a x coordinate
        CGFloat rectX = (((x + 2*M_PI)/(4*M_PI)) * width) + startX;
        
        // convert the f(x) value to a y coordinate
        CGFloat rectY = ((fx/3) * height) + startY;
        
        CGPathAddLineToPoint(path, NULL, rectX, rectY);        
    }

    [shapeLayer setPath:path];
    [shapeLayer setNeedsDisplay];
    CFRelease(path);    
}

- (void)setFormulaConstant:(CGFloat)constant
{
    // alpha as in the alpha of the equation (not opacity alpha)
    formulaConstant = constant;
    [self updateGraph];
}


@end
