//
//  MemoryLeakAppDelegate.m
//  MemoryLeak
//
//  Created by 石田 光一 on 10/05/19.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MemoryLeakAppDelegate.h"
#import "MemoryLeakViewController.h"

@implementation MemoryLeakAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
