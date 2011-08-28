
/*
     File: TiledScrollView.m
 Abstract: UIScrollView subclass to manage tiled content.
 
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
#import "TiledScrollView.h"
#import "TapDetectingView.h"
#define DEFAULT_TILE_SIZE 100

#define ANNOTATE_TILES YES

@interface TiledScrollView ()
- (void)annotateTile:(UIView *)tile;
- (void)updateResolution;
@end

@implementation TiledScrollView
@synthesize tileSize;
@synthesize tileContainerView;
@synthesize dataSource;
@dynamic minimumResolution;
@dynamic maximumResolution;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // we will recycle tiles by removing them from the view and storing them here
        reusableTiles = [[NSMutableSet alloc] init];
        
        // we need a tile container view to hold all the tiles. This is the view that is returned
        // in the -viewForZoomingInScrollView: delegate method, and it also detects taps.
        tileContainerView = [[TapDetectingView alloc] initWithFrame:CGRectZero];
        [tileContainerView setBackgroundColor:[UIColor redColor]];
        [self addSubview:tileContainerView];
        [self setTileSize:CGSizeMake(DEFAULT_TILE_SIZE, DEFAULT_TILE_SIZE)];

        // no rows or columns are visible at first; note this by making the firsts very high and the lasts very low
        firstVisibleRow = firstVisibleColumn = NSIntegerMax;
        lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
                
        // the TiledScrollView is its own UIScrollViewDelegate, so we can handle our own zooming.
        // We need to return our tileContainerView as the view for zooming, and we also need to receive
        // the scrollViewDidEndZooming: delegate callback so we can update our resolution.
        [super setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [reusableTiles release];
    [tileContainerView release];
    [super dealloc];
}

// we don't synthesize our minimum/maximum resolution accessor methods because we want to police the values of these ivars
- (int)minimumResolution { return minimumResolution; }
- (int)maximumResolution { return maximumResolution; }
- (void)setMinimumResolution:(int)res { minimumResolution = MIN(res, 0); } // you can't have a minimum resolution greater than 0
- (void)setMaximumResolution:(int)res { maximumResolution = MAX(res, 0); } // you can't have a maximum resolution less than 0

- (UIView *)dequeueReusableTile {
    UIView *tile = [reusableTiles anyObject];
    if (tile) {
        // the only object retaining the tile is our reusableTiles set, so we have to retain/autorelease it
        // before returning it so that it's not immediately deallocated when we remove it from the set
        [[tile retain] autorelease];
        [reusableTiles removeObject:tile];
    }
    return tile;
}

- (void)reloadData {
    // recycle all tiles so that every tile will be replaced in the next layoutSubviews
    for (UIView *view in [tileContainerView subviews]) {
        [reusableTiles addObject:view];
        [view removeFromSuperview];
    }
    
    // no rows or columns are now visible; note this by making the firsts very high and the lasts very low
    firstVisibleRow = firstVisibleColumn = NSIntegerMax;
    lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
    
    [self setNeedsLayout];
}

- (void)reloadDataWithNewContentSize:(CGSize)size {
    
    // since we may have changed resolutions, which changes our maximum and minimum zoom scales, we need to 
    // reset all those values. After calling this method, the caller should change the maximum/minimum zoom scales
    // if it wishes to permit zooming.
    
    [self setZoomScale:1.0];
    [self setMinimumZoomScale:1.0];
    [self setMaximumZoomScale:1.0];
    resolution = 0;
    
    // now that we've reset our zoom scale and resolution, we can safely set our contentSize. 
    [self setContentSize:size];
    
    // we also need to change the frame of the tileContainerView so its size matches the contentSize
    [tileContainerView setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    [self reloadData];
}

/***********************************************************************************/
/* Most of the work of tiling is done in layoutSubviews, which we override here.   */
/* We recycle the tiles that are no longer in the visible bounds of the scrollView */
/* and we add any tiles that should now be present but are missing.                */
/***********************************************************************************/
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect visibleBounds = [self bounds];

    // first recycle all tiles that are no longer visible
    for (UIView *tile in [tileContainerView subviews]) {
        
        // We want to see if the tiles intersect our (i.e. the scrollView's) bounds, so we need to convert their
        // frames to our own coordinate system
        CGRect scaledTileFrame = [tileContainerView convertRect:[tile frame] toView:self];

        // If the tile doesn't intersect, it's not visible, so we can recycle it
        if (! CGRectIntersectsRect(scaledTileFrame, visibleBounds)) {
            [reusableTiles addObject:tile];
            [tile removeFromSuperview];
        }
    }
    
    // calculate which rows and columns are visible by doing a bunch of math.
    float scaledTileWidth  = [self tileSize].width  * [self zoomScale];
    float scaledTileHeight = [self tileSize].height * [self zoomScale];
    int maxRow = floorf([tileContainerView frame].size.height / scaledTileHeight); // this is the maximum possible row
    int maxCol = floorf([tileContainerView frame].size.width  / scaledTileWidth);  // and the maximum possible column
    int firstNeededRow = MAX(0, floorf(visibleBounds.origin.y / scaledTileHeight));
    int firstNeededCol = MAX(0, floorf(visibleBounds.origin.x / scaledTileWidth));
    int lastNeededRow  = MIN(maxRow, floorf(CGRectGetMaxY(visibleBounds) / scaledTileHeight));
    int lastNeededCol  = MIN(maxCol, floorf(CGRectGetMaxX(visibleBounds) / scaledTileWidth));
        
    // iterate through needed rows and columns, adding any tiles that are missing
    for (int row = firstNeededRow; row <= lastNeededRow; row++) {
        for (int col = firstNeededCol; col <= lastNeededCol; col++) {

            BOOL tileIsMissing = (firstVisibleRow > row || firstVisibleColumn > col || 
                                  lastVisibleRow  < row || lastVisibleColumn  < col);
            
            if (tileIsMissing) {
                UIView *tile = [dataSource tiledScrollView:self tileForRow:row column:col resolution:resolution];
                                
                // set the tile's frame so we insert it at the correct position
                CGRect frame = CGRectMake([self tileSize].width * col, [self tileSize].height * row, [self tileSize].width, [self tileSize].height);
                [tile setFrame:frame];
                [tileContainerView addSubview:tile];
                
                // annotateTile draws green lines and tile numbers on the tiles for illustration purposes. 
                [self annotateTile:tile];
                
            }
        }
    }
    
    // update our record of which rows/cols are visible
    firstVisibleRow = firstNeededRow; firstVisibleColumn = firstNeededCol;
    lastVisibleRow  = lastNeededRow;  lastVisibleColumn  = lastNeededCol;            
}


/*****************************************************************************************/
/* The following method handles changing the resolution of our tiles when our zoomScale  */
/* gets below 50% or above 100%. When we fall below 50%, we lower the resolution 1 step, */
/* and when we get above 100% we raise it 1 step. The resolution is stored as a power of */
/* 2, so -1 represents 50%, and 0 represents 100%, and so on.                            */
/*****************************************************************************************/
- (void)updateResolution {
    
    // delta will store the number of steps we should change our resolution by. If we've fallen below
    // a 25% zoom scale, for example, we should lower our resolution by 2 steps so delta will equal -2.
    // (Provided that lowering our resolution 2 steps stays within the limit imposed by minimumResolution.)
    int delta = 0;
    
    // check if we should decrease our resolution
    for (int thisResolution = minimumResolution; thisResolution < resolution; thisResolution++) {
        int thisDelta = thisResolution - resolution;
        // we decrease resolution by 1 step if the zoom scale is <= 0.5 (= 2^-1); by 2 steps if <= 0.25 (= 2^-2), and so on
        float scaleCutoff = pow(2, thisDelta); 
        if ([self zoomScale] <= scaleCutoff) {
            delta = thisDelta;
            break;
        } 
    }
    
    // if we didn't decide to decrease the resolution, see if we should increase it
    if (delta == 0) {
        for (int thisResolution = maximumResolution; thisResolution > resolution; thisResolution--) {
            int thisDelta = thisResolution - resolution;
            // we increase by 1 step if the zoom scale is > 1 (= 2^0); by 2 steps if > 2 (= 2^1), and so on
            float scaleCutoff = pow(2, thisDelta - 1); 
            if ([self zoomScale] > scaleCutoff) {
                delta = thisDelta;
                break;
            } 
        }
    }
    
    if (delta != 0) {
        resolution += delta;
        
        // if we're increasing resolution by 1 step we'll multiply our zoomScale by 0.5; up 2 steps multiply by 0.25, etc
        // if we're decreasing resolution by 1 step we'll multiply our zoomScale by 2.0; down 2 steps by 4.0, etc
        float zoomFactor = pow(2, delta * -1); 
        
        // save content offset, content size, and tileContainer size so we can restore them when we're done
        // (contentSize is not equal to containerSize when the container is smaller than the frame of the scrollView.)
        CGPoint contentOffset = [self contentOffset];   
        CGSize  contentSize   = [self contentSize];
        CGSize  containerSize = [tileContainerView frame].size;
        
        // adjust all zoom values (they double as we cut resolution in half)
        [self setMaximumZoomScale:[self maximumZoomScale] * zoomFactor];
        [self setMinimumZoomScale:[self minimumZoomScale] * zoomFactor];
        [super setZoomScale:[self zoomScale] * zoomFactor];
        
        // restore content offset, content size, and container size
        [self setContentOffset:contentOffset];
        [self setContentSize:contentSize];
        [tileContainerView setFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];    
        
        // throw out all tiles so they'll reload at the new resolution
        [self reloadData];        
    }        
}
        
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return tileContainerView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    if (scrollView == self) {
        
        // the following two lines are a bug workaround that will no longer be needed after OS 3.0.
        [super setZoomScale:scale+0.01 animated:NO];
        [super setZoomScale:scale animated:NO];
        
        // after a zoom, check to see if we should change the resolution of our tiles
        [self updateResolution];
    }
}

#pragma mark UIScrollView overrides

// the scrollViewDidEndZooming: delegate method is only called after an *animated* zoom. We also need to update our 
// resolution for non-animated zooms. So we also override the new setZoomScale:animated: method on UIScrollView
- (void)setZoomScale:(float)scale animated:(BOOL)animated {
    [super setZoomScale:scale animated:animated];
    
    // the delegate callback will catch the animated case, so just cover the non-animated case
    if (!animated) {
        [self updateResolution];
    }
}

// We override the setDelegate: method because we can't manage resolution changes unless we are our own delegate.
- (void)setDelegate:(id)delegate {
    NSLog(@"You can't set the delegate of a TiledZoomableScrollView. It is its own delegate.");
}


#pragma mark
#define LABEL_TAG 3

- (void)annotateTile:(UIView *)tile {
    static int totalTiles = 0;
    
    UILabel *label = (UILabel *)[tile viewWithTag:LABEL_TAG];
    if (!label) {  
        totalTiles++;  // if we haven't already added a label to this tile, it's a new tile
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 80, 50)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:LABEL_TAG];
        [label setTextColor:[UIColor greenColor]];
        [label setShadowColor:[UIColor blackColor]];
        [label setShadowOffset:CGSizeMake(1.0, 1.0)];
        [label setFont:[UIFont boldSystemFontOfSize:40]];
        [label setText:[NSString stringWithFormat:@"%d", totalTiles]];
        [tile addSubview:label];
        [label release];
        [[tile layer] setBorderWidth:2];
        [[tile layer] setBorderColor:[[UIColor greenColor] CGColor]];
    }
    
    [tile bringSubviewToFront:label];
}


@end
