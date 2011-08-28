//
//  ColorPaletteAppDelegate.m
//  ColorPalette
//
//  Created by 石田 光一 on 10/05/29.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ColorPaletteAppDelegate.h"


@implementation ColorPaletteAppDelegate

@synthesize window;
@synthesize tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];

	return YES;
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/


// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
	NSLog(@"@%@ : [%s] is called.", [self class], _cmd);

}



- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

