/*
 
 File: TabularDataCell.m
 
 Abstract: The table cell presenting the formula data in tabular form
 
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

#import "TabularDataCell.h"

@implementation TabularDataCell

@synthesize row;
@synthesize formulaConstant;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self == nil )
    {
        return nil;
    }
    
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 100, 30)];
    [label1 setFont:[UIFont fontWithName:@"Arial" size:14]];
    [self addSubview:label1];
    [label1 release];
    
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(105, 10, 100, 30)];
    [label2 setFont:[UIFont fontWithName:@"Courier" size:18]];
    [self addSubview:label2];
    [label2 release];
    
    return self;
}

- (void)setRow:(NSInteger)r
{
    row = r;
    
    // normalize from r/100 rows to an x value between -2∏ -> 2∏
    CGFloat x = ((row / 100.0) * 4*M_PI) - (2*M_PI);
    CGFloat fx = formulaConstant * x * sin(x);
    
    label1.text = [NSString stringWithFormat:@"f(%.2f) = ",x];
    label2.text = [NSString stringWithFormat:@"%0.5f",fx]; 
    
    // update the accessibility label with an appropriate string representing the data succinctly
    [self setAccessibilityLabel:[NSString stringWithFormat:@"f of %.2f equals %.2f",x, fx]];
}

@end
