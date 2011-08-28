/*
 
 File: ViewController.m
 
 Abstract: View Controller
 
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

#import "ViewController.h"
#import "TabularDataCell.h"
#import <AudioToolbox/AudioServices.h>

@implementation ViewController

- (void)updateGraphingView
{
    // set the consntant (alpha) value for the graph view
    CGFloat value = [valueField.text floatValue]; 
    
    if ( value < slider.minimumValue )
    {
        value = slider.minimumValue;
    }
    else if ( value > slider.maximumValue )
    {
        value = slider.maximumValue;
    }
    
    graphingView.formulaConstant = value;
}

- (void)viewDidLoad 
{
    // update the graph view
    [self updateGraphingView];

    // set the hint for the stop watch button
    [stopWatch setAccessibilityHint:@"Toggles animation."];    

    // allow updates of graph
    shouldUpdateGraph = YES;
    
    [super viewDidLoad];
}

- (void)updateLabel:(NSString *)text
{
    resultLabel.text = text;
}

- (IBAction)touchesEndedForGraphingView:(id)sender event:(UIEvent *)event
{
    // handle touches in the graph view
    CGPoint touchUp = [[[event allTouches] anyObject] locationInView:graphingView];
    if ( touchUp.x < 100 )
    {
        [self updateLabel:[NSString stringWithFormat:@"f(%.2f) = %.5f",-M_PI/2, graphingView.formulaConstant * -M_PI/2 * sin(-M_PI/2)]];
    }
    else if ( touchUp.x < 200 )
    {
        [self updateLabel:[NSString stringWithFormat:@"f(%.2f) = %.5f",0, graphingView.formulaConstant * 0 * sin(0)]];        
    }
    else if ( touchUp.x < 300 )
    {
        [self updateLabel:[NSString stringWithFormat:@"f(%.2f) = %.5f",M_PI/2, graphingView.formulaConstant * M_PI/2 * sin(M_PI/2)]];
    }
}

- (void)_countdownValue
{
    // update the text field and graph based on whether the stop watch is on or off
    if ( !stopWatchStateOn )
    {
        return;
    }

    CGFloat value = [valueField.text floatValue];
    
    if ( value > slider.maximumValue )
    {
        stopWatchDirectionUp = NO;
    }
    else if ( value < slider.minimumValue )
    {
        stopWatchDirectionUp = YES;        
    }
    
    CGFloat step = .005f;
    if ( stopWatchDirectionUp )
    {
        value += step;
    }
    else
    {
        value -= step;        
    }
    
    slider.value = value;
    
    valueField.text = [NSString stringWithFormat:@"%.5f", value];
    [self updateGraphingView];

    [self performSelector:@selector(_countdownValue) withObject:nil afterDelay:.02f];
}

- (IBAction)stopWatchButtonWasPressed:(id)sender
{
    if ( stopWatchStateOn )
    {
        stopWatchStateOn = NO;
        [stopWatch setImage:[UIImage imageNamed:@"countdown-off.png"] forState:UIControlStateNormal];
        
        // update the accessibility label to indicate what pressing the button now will do
        [stopWatch setAccessibilityLabel:@"Start animating graph"];
    }
    else
    {
        stopWatchStateOn = YES;
        [stopWatch setImage:[UIImage imageNamed:@"countdown-on.png"] forState:UIControlStateNormal];
        [self performSelector:@selector(_countdownValue) withObject:nil afterDelay:0.0f];

        // update the accessibility label to indicate what pressing the button now will do
        [stopWatch setAccessibilityLabel:@"Stop animating graph"];
    }
    
    // play sound when pressed
    static SystemSoundID soundId = 0;
    if ( soundId == 0 )
    {
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sound" ofType:@"aiff"]], &soundId);
    }
    
    AudioServicesPlaySystemSound(soundId);
}

- (IBAction)textFieldChanged:(id)sender
{
    // only allow the text field to update in this iteration
    if ( shouldUpdateGraph )
    {
        shouldUpdateGraph = NO;
        slider.value = [valueField.text floatValue];
        [self updateGraphingView];
        shouldUpdateGraph = YES;
    }
}

- (IBAction)sliderWasChanged:(id)sender
{
    CGFloat value = [slider value];
    
    // only allow the slider to update in this iteration
    if ( shouldUpdateGraph )
    {
        shouldUpdateGraph = NO;
        valueField.text = [NSString stringWithFormat:@"%0.5f",value];
        [self updateGraphingView];
        shouldUpdateGraph = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:NO];
    return YES;
}

#pragma mark -
#pragma mark Tabular Data View

- (IBAction)tableButtonWasPressed:(id)sender
{
    CGRect frame = tabularDataView.frame;
    frame.origin.y = frame.size.height;
    
    if ( [tabularDataView superview] == nil )
    {
        [self.view addSubview:tabularDataView];
    }
        
    tabularDataView.frame = frame;
    [tabularDataTableView reloadData];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    frame.origin.y = 0;
    tabularDataView.frame = frame;
    [UIView commitAnimations];

    // when the table view slides in, its significant enough that a screen change notification should be posted
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TabularDataCell *cell = [[[TabularDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.formulaConstant = [valueField.text floatValue];
    cell.row = indexPath.row;
    return cell;
}

- (IBAction)doneButtonPressed
{
    CGRect frame = tabularDataView.frame;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    frame.origin.y = frame.size.height;
    tabularDataView.frame = frame;
    [UIView commitAnimations];

    // when the table view goes away, its significant enough that a screen change notification should be posted
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

@end
