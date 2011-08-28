//
//  MemoryLeakAppDelegate.h
//  MemoryLeak
//
//  Created by 石田 光一 on 10/05/19.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MemoryLeakViewController;

@interface MemoryLeakAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MemoryLeakViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MemoryLeakViewController *viewController;

@end

