/*
     File: CompositeSubviewBasedApplicationCell.m
 Abstract: The subclass of ApplicationCell that uses a single view to draw the content.
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

#import "CompositeSubviewBasedApplicationCell.h"

#define MAX_RATING 5.0

@interface CompositeSubviewBasedApplicationCellContentView : UIView
{
    ApplicationCell *_cell;
    BOOL _highlighted;
}

@end

@implementation CompositeSubviewBasedApplicationCellContentView

- (id)initWithFrame:(CGRect)frame cell:(ApplicationCell *)cell
{
    if (self = [super initWithFrame:frame]) {
        _cell = cell;
        
        self.opaque = YES;
        self.backgroundColor = _cell.backgroundColor;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [_cell.icon drawAtPoint:CGPointMake(11.0, 5.0)];

    _highlighted ? [[UIColor whiteColor] set] : [[UIColor blackColor] set];
    [_cell.name drawAtPoint:CGPointMake(81.0, 22.0) withFont:[UIFont boldSystemFontOfSize:17.0]];
    
    _highlighted ? [[UIColor whiteColor] set] : [[UIColor colorWithWhite:0.23 alpha:1.0] set];
    [_cell.publisher drawAtPoint:CGPointMake(81.0, 8.0) withFont:[UIFont boldSystemFontOfSize:11.0]];
    
    [[NSString stringWithFormat:@"%d Ratings", _cell.numRatings] drawAtPoint:CGPointMake(157.0, 46.0) withFont:[UIFont systemFontOfSize:11.0]];
    
    CGSize priceSize = [_cell.price sizeWithFont:[UIFont boldSystemFontOfSize:11.0]];
    [_cell.price drawAtPoint:CGPointMake(self.bounds.size.width - priceSize.width - 8.0, 28.0) withFont:[UIFont boldSystemFontOfSize:11.0]];
    
    CGPoint ratingImageOrigin = CGPointMake(81.0, 45.0);
    UIImage *ratingBackgroundImage = [UIImage imageNamed:@"StarsBackground.png"];
    [ratingBackgroundImage drawAtPoint:ratingImageOrigin];
    UIImage *ratingForegroundImage = [UIImage imageNamed:@"StarsForeground.png"];
    UIRectClip(CGRectMake(ratingImageOrigin.x, ratingImageOrigin.y, ratingForegroundImage.size.width * (_cell.rating / MAX_RATING), ratingForegroundImage.size.height));
    [ratingForegroundImage drawAtPoint:ratingImageOrigin];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted
{
    return _highlighted;
}

@end

@implementation CompositeSubviewBasedApplicationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        cellContentView = [[CompositeSubviewBasedApplicationCellContentView alloc] initWithFrame:CGRectInset(self.contentView.bounds, 0.0, 1.0) cell:self];
        cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cellContentView.contentMode = UIViewContentModeRedraw;
        [self.contentView addSubview:cellContentView];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    [UIView setAnimationsEnabled:NO];
    CGSize contentSize = cellContentView.bounds.size;
    cellContentView.contentStretch = CGRectMake(225.0 / contentSize.width, 0.0, (contentSize.width - 260.0) / contentSize.width, 1.0);
    [UIView setAnimationsEnabled:YES];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    cellContentView.backgroundColor = backgroundColor;
}

- (void)dealloc
{
    [cellContentView release];
    
    [super dealloc];
}

@end
