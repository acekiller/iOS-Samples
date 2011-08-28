/*
     File: WeatherAnnotationView.m
 Abstract: The UIView or MKAnnotationView for drawing each weather location's data.
 
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

#import "WeatherAnnotationView.h"
#import "WeatherItem.h"


@implementation WeatherAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(60.0, 85.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(30.0, 42.0);
    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    WeatherItem *weatherItem = (WeatherItem *)self.annotation;
    if (weatherItem != nil)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1);
        
        // draw the gray pointed shape:
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 14.0, 0.0);
        CGPathAddLineToPoint(path, NULL, 0.0, 0.0); 
        CGPathAddLineToPoint(path, NULL, 55.0, 50.0); 
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGPathRelease(path);
        
        // draw the cyan rounded box
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 15.0, 0.5);
        CGPathAddArcToPoint(path, NULL, 59.5, 00.5, 59.5, 5.0, 5.0);
        CGPathAddArcToPoint(path, NULL, 59.5, 69.5, 55.0, 69.5, 5.0);
        CGPathAddArcToPoint(path, NULL, 10.5, 69.5, 10.5, 64.0, 5.0);
        CGPathAddArcToPoint(path, NULL, 10.5, 00.5, 15.0, 0.5, 5.0);
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, [UIColor cyanColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGPathRelease(path);
        
        NSInteger high = [weatherItem.high integerValue];
        NSInteger low = [weatherItem.low integerValue];

        // draw the temperature string and weather graphic
        NSString *temperature = [NSString stringWithFormat:@"%@\n%d / %d", weatherItem.place, high, low];
        [[UIColor blackColor] set];
        [temperature drawInRect:CGRectMake(15.0, 5.0, 50.0, 40.0) withFont:[UIFont systemFontOfSize:11.0]];
        NSString *imageName = nil;
        switch ([weatherItem.condition integerValue])
        {
            case Sunny:
                imageName = @"sunny.png";
                break;
            case PartlyCloudy:
                imageName = @"partly_cloudy.png";
                break;
            case Cloudy:
                imageName = @"cloudy.png";             
                break;
            default:
                imageName = @"partly_cloudy.png";
                break;
        }
        [[UIImage imageNamed:imageName] drawInRect:CGRectMake(12.5, 28.0, 45.0, 45.0)];
    }
}

@end
