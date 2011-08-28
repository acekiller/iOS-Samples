/*
    File:       PickListController.m

    Contains:   Runs a pick list table view.

    Written by: DTS

    Copyright:  Copyright (c) 2010 Apple Inc. All Rights Reserved.

    Disclaimer: IMPORTANT: This Apple software is supplied to you by Apple Inc.
                ("Apple") in consideration of your agreement to the following
                terms, and your use, installation, modification or
                redistribution of this Apple software constitutes acceptance of
                these terms.  If you do not agree with these terms, please do
                not use, install, modify or redistribute this Apple software.

                In consideration of your agreement to abide by the following
                terms, and subject to these terms, Apple grants you a personal,
                non-exclusive license, under Apple's copyrights in this
                original Apple software (the "Apple Software"), to use,
                reproduce, modify and redistribute the Apple Software, with or
                without modifications, in source and/or binary forms; provided
                that if you redistribute the Apple Software in its entirety and
                without modifications, you must retain this notice and the
                following text and disclaimers in all such redistributions of
                the Apple Software. Neither the name, trademarks, service marks
                or logos of Apple Inc. may be used to endorse or promote
                products derived from the Apple Software without specific prior
                written permission from Apple.  Except as expressly stated in
                this notice, no other rights or licenses, express or implied,
                are granted by Apple herein, including but not limited to any
                patent rights that may be infringed by your derivative works or
                by other works in which the Apple Software may be incorporated.

                The Apple Software is provided by Apple on an "AS IS" basis. 
                APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
                WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT,
                MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING
                THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
                COMBINATION WITH YOUR PRODUCTS.

                IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT,
                INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
                TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
                DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY
                OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
                OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY
                OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR
                OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF
                SUCH DAMAGE.

*/

#import "PickListController.h"

@interface PickListController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain, readwrite) UIView *       topView;
@property (nonatomic, retain, readwrite) UITableView *  tableView;
@end

@implementation PickListController

@synthesize pickList = _pickList;
@synthesize delegate = _delegate;

@synthesize topView   = _topView;
@synthesize tableView = _tableView;

- (id)initWithPickList:(NSArray *)pickList
{
    assert(pickList != nil);
    assert(pickList.count != 0);
    self = [super init];
    if (self != nil) {
        self->_pickList = [pickList copy];
        assert(self->_pickList != nil);
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString *)pickListFilePath
{
    NSArray *       pickListArray;
    
    assert(pickListFilePath != nil);
    
    pickListArray = [NSArray arrayWithContentsOfFile:pickListFilePath];
    assert([pickListArray isKindOfClass:[NSArray class]]);
    
    return [self initWithPickList:pickListArray];
}

- (id)initWithPickListNamed:(NSString *)pickListName bundle:(NSBundle *)bundle
{
    NSString *      pickListPath;
    
    assert(pickListName != nil);
    // bundleName may be nil
    
    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    
    pickListPath = [bundle pathForResource:pickListName ofType:@"plist"];
    assert(pickListPath != nil);

    return [self initWithContentsOfFile:pickListPath];
}

- (void)dealloc
{
    assert(self->_tableView == nil);
    assert(self->_topView == nil);
    [self->_pickList release];
    [super dealloc];
}

#pragma mark * Attach and detach

- (CGRect)_tableViewFrame
    // Calculates the frame for the pick list based on the coordinates of the top 
    // view and the size of the containing view (that is, the top view's superview, 
    // which will also be the pick list's superview).
{
    CGRect      topViewFrame;
    CGRect      containerViewBounds;
    CGRect      frame;

    topViewFrame = self.topView.frame;
    containerViewBounds = self.topView.superview.bounds;
    
    frame.origin.x    = containerViewBounds.origin.x;
    frame.origin.y    = topViewFrame.origin.y + topViewFrame.size.height;
    frame.size.height = containerViewBounds.size.height - (topViewFrame.origin.y + topViewFrame.size.height);
    frame.size.width  = containerViewBounds.size.width;

    return frame;
}

- (void)attachBelowView:(UIView *)topView
{
    assert(topView != nil);
    
    self.topView = topView;
    
    assert(self.tableView == nil);
    self.tableView = [[[UITableView alloc] initWithFrame:[self _tableViewFrame] style:UITableViewStylePlain] autorelease];

    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    [self.topView.superview addSubview:self.tableView];
    
    [self.tableView flashScrollIndicators];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardDidShow:)  name:UIKeyboardDidShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)detach
{
    if (self.tableView != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification  object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

        self.topView = nil;

        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        [self.tableView removeFromSuperview];
        self.tableView = nil;
    }
}

#pragma mark * Keyboard handling

- (void)_keyboardDidShow:(NSNotification *)note
    // A notification callback, called when the keyboard is shown.  We recalculate 
    // the size of the pick list table view to fit between the bottom of the top 
    // view and the top of the keyboard.
{
    NSDictionary *  userInfo;
    CGRect          frame;
    CGRect          keyboardFrame;
    CGPoint         keyboardCenter;
    CGPoint         keyboardTopInScreenCoordinates;
    CGPoint         keyboardTopInWindowCoordinates;
    CGPoint         keyboardTop;
    
    userInfo = [note userInfo];
    assert(userInfo != nil);
    
    // Get the raw keyboard info from the notification.
    
    keyboardCenter = [[userInfo objectForKey:UIKeyboardCenterEndUserInfoKey] CGPointValue];
    keyboardFrame  = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey   ] CGRectValue ];
    
    // Calculate the keyboard's top in screen coordinates and then map it through to 
    // our view's coordinates.
    
    // Dude, they said there'd be no maths!
    
    keyboardTopInScreenCoordinates = keyboardCenter;
    keyboardTopInScreenCoordinates.y -= (keyboardFrame.size.height / 2);
    keyboardTopInWindowCoordinates = [self.topView.window convertPoint:keyboardTopInScreenCoordinates fromWindow:nil];
    keyboardTop = [self.topView.window convertPoint:keyboardTopInWindowCoordinates toView:self.topView.superview];
    
    // Resize the table view to sit between the top view and the keyboard.
    
    frame = self.tableView.frame;
    frame.size.height = keyboardTop.y - frame.origin.y;
    self.tableView.frame = frame;
}

- (void)_keyboardWillHide:(NSNotification *)note
    // A notification callback, called when the keyboard is hidden.  We revert the 
    // pick list table view to its default size.
{
    #pragma unused(note)
    self.tableView.frame = [self _tableViewFrame];
}

#pragma mark * Table view callbacks

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    #pragma unused(tv)
    #pragma unused(section)
    assert(tv == self.tableView);
    assert(section == 0);

    return self.pickList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #pragma unused(tv)
    #pragma unused(indexPath)
    UITableViewCell *	cell;

    assert(tv == self.tableView);
    assert(indexPath != nil);
    assert(indexPath.section == 0);
    assert(indexPath.row < self.pickList.count);

    cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        assert(cell != nil);

        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    cell.textLabel.text = [self.pickList objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    #pragma unused(tv)
    assert(tv == self.tableView);
    assert(indexPath != nil);
    assert(indexPath.section == 0);
    assert(indexPath.row < self.pickList.count);

    // It's likely that the client is going to release its reference to us in 
    // response to to this callback, so we ensure that our reference persists 
    // while everything shuts down.
    
    [[self retain] autorelease];
    [self.delegate pickList:self didPick:[self.pickList objectAtIndex:indexPath.row]];
}

@end
