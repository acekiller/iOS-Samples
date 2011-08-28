//
//  IPhoneSDKRecipeAppDelegate.h
//  IPhoneSDKRecipe
//
//  Created by 石田 光一 on 10/05/23.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPhoneSDKRecipeViewController;

@interface IPhoneSDKRecipeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    IPhoneSDKRecipeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet IPhoneSDKRecipeViewController *viewController;

@end

