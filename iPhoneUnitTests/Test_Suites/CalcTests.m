/*
     File: CalcTests.m
 Abstract: This file implements unit tests for the Calc application.
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
 
#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

// Test-subject headers.
#import "CalcAppDelegate.h"
#import "CalcViewController.h"


@interface CalcTests : SenTestCase {
   CalcAppDelegate    *appDelegate;
   CalcViewController *viewController;
   UIView             *calcView;
}
@end

@implementation CalcTests

/* The setUp method is called automatically for each test-case method (methods whose name starts with 'test').
 */
- (void) setUp {
   appDelegate    = [[UIApplication sharedApplication] delegate];
   viewController = appDelegate.calcViewController;
   calcView       = viewController.view;
}

- (void) testAppDelegate {
    STAssertNotNil(appDelegate, @"Cannot find the application delegate");
}

/* testAddition performs a chained addition test.
 * The test has two parts:
 * 1. Check: 6 + 2 = 8.
 * 2. Check: display + 2 = 10.
 */
- (void) testAddition {
   [viewController press:[calcView viewWithTag: 6]];  // 6
   [viewController press:[calcView viewWithTag:13]];  // +
   [viewController press:[calcView viewWithTag: 2]];  // 2
   [viewController press:[calcView viewWithTag:12]];  // =   
   STAssertTrue([[viewController.displayField text] isEqualToString:@"8"], @"Part 1 failed.");
   
   [viewController press:[calcView viewWithTag:13]];  // +
   [viewController press:[calcView viewWithTag: 2]];  // 2
   [viewController press:[calcView viewWithTag:12]];  // =      
   STAssertTrue([[viewController.displayField text] isEqualToString:@"10"], @"Part 2 failed.");
}

/* testSubtraction performs a simple subtraction test.
 * Check: 6 - 2 = 4.
 */
- (void) testSubtraction {
   [viewController press:[calcView viewWithTag: 6]];  // 6
   [viewController press:[calcView viewWithTag:14]];  // -
   [viewController press:[calcView viewWithTag: 2]];  // 2
   [viewController press:[calcView viewWithTag:12]];  // =   
   STAssertTrue([[viewController.displayField text] isEqualToString:@"4"], @"");
}

/* testDivision performs a simple division test.
 * Check: 25 / 4 = 6.25.
 */
- (void) testDivision {
   [viewController press:[calcView viewWithTag: 2]];  // 2
   [viewController press:[calcView viewWithTag: 5]];  // 5
   [viewController press:[calcView viewWithTag:16]];  // /
   [viewController press:[calcView viewWithTag: 4]];  // 4
   [viewController press:[calcView viewWithTag:12]];  // =   
   STAssertTrue([[viewController.displayField text] isEqualToString:@"6.25"], @"");
}

/* testMultiplication performs a simple multiplication test.
 * Check: 19 x 8 = 152.
 */
- (void) testMultiplication {
   [viewController press:[calcView viewWithTag: 1]];  // 1
   [viewController press:[calcView viewWithTag: 9]];  // 9
   [viewController press:[calcView viewWithTag:15]];  // x
   [viewController press:[calcView viewWithTag: 8]];  // 8
   [viewController press:[calcView viewWithTag:12]];  // =
   STAssertTrue([[viewController.displayField text] isEqualToString:@"152"], @"");
}

/* testDelete tests the functionality of the D (Delete) key.
 * 1. Enter the number 1987 into the calculator.
 * 2. Delete each digit, and test the display to ensure
 *    the correct display contains the expected value after each D press.
 */
- (void) testDelete {
   [viewController press:[calcView viewWithTag: 1]];  // 1
   [viewController press:[calcView viewWithTag: 9]];  // 9
   [viewController press:[calcView viewWithTag: 8]];  // 8
   [viewController press:[calcView viewWithTag: 7]];  // 7
   STAssertTrue([[viewController.displayField text] isEqualToString:@"1987"], @"Part 1 failed.");
   
   [viewController press:[calcView viewWithTag:19]];  // D (delete)
   STAssertTrue([[viewController.displayField text] isEqualToString:@"198"],  @"Part 2 failed.");      

   [viewController press:[calcView viewWithTag:19]];  // D (delete)
   STAssertTrue([[viewController.displayField text] isEqualToString:@"19"],   @"Part 3 failed.");      

   [viewController press:[calcView viewWithTag:19]];  // D (delete)
   STAssertTrue([[viewController.displayField text] isEqualToString:@"1"],    @"Part 4 failed.");      

   [viewController press:[calcView viewWithTag:19]];  // D (delete)
   STAssertTrue([[viewController.displayField text] isEqualToString:@"0"],    @"Part 5 failed.");
}

/* testClear tests the functionality of the C (Clear).
 * 1. Clear the display.
 *  - Enter the calculation 25 / 4.
 *  - Press C.
 *  - Ensure the display contains the value 0.
 * 2. Perform corrected computation.
 *  - Press 5, =.
 *  - Ensure the display contains the value 5.
 * 3. Ensure pressign C twice clears all.
 *  - Enter the calculation 19 x 8.
 *  - Press C (clears the display).
 *  - Press C (clears the operand).
 *  - Press +, 2, =.
 *  - Ensure the display contains the value 2.
 */
- (void) testClear {
   [viewController press:[calcView viewWithTag: 2]];  // 2
   [viewController press:[calcView viewWithTag: 5]];  // 5
   [viewController press:[calcView viewWithTag:16]];  // /
   [viewController press:[calcView viewWithTag: 4]];  // 4
   [viewController press:[calcView viewWithTag:11]];  // C (clear)
   STAssertTrue([[viewController.displayField text] isEqualToString:@"0"], @"Part 1 failed.");
   
   [viewController press:[calcView viewWithTag: 5]];  // 5
   [viewController press:[calcView viewWithTag:12]];  // =
   STAssertTrue([[viewController.displayField text] isEqualToString:@"5"], @"Part 2 failed.");
   
   [viewController press:[calcView viewWithTag: 1]];  // 1
   [viewController press:[calcView viewWithTag: 9]];  // 9
   [viewController press:[calcView viewWithTag:15]];  // x
   [viewController press:[calcView viewWithTag: 8]];  // 8
   [viewController press:[calcView viewWithTag:11]];  // C (clear)
   [viewController press:[calcView viewWithTag:11]];  // C (all clear)
   [viewController press:[calcView viewWithTag:13]];  // +
   [viewController press:[calcView viewWithTag: 2]];  // 2
   [viewController press:[calcView viewWithTag:12]];  // =   
   STAssertTrue([[viewController.displayField text] isEqualToString:@"2"], @"Part 3 failed.");
}

@end
