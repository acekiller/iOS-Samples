//
//  IPhoneSDKRecipeAppDelegate.m
//  IPhoneSDKRecipe
//
//  Created by 石田 光一 on 10/05/23.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "IPhoneSDKRecipeAppDelegate.h"
#import "IPhoneSDKRecipeViewController.h"

@implementation IPhoneSDKRecipeAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	// 自動ロック無効の設定
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	// ULRエンコーディング
	[ChapterTwo URLEncodingTest];
	
	// Array Randomized
	[ChapterTwo NSArrayRandamizedResult];
	
	return YES;
}

// 省電力モードになったとき
- (void)applicationSignificantTimeChange:(UIApplication *)application
{
	
}

// ロックされたとき
- (void)applicationWillResignActive:(UIApplication *)application
{
	
}

// ホームボタンを押されたとき
- (void)applicationWillTerminate:(UIApplication *)application
{
	
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
