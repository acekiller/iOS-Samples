//
//  IPhoneSDKRecipeViewController.h
//  IPhoneSDKRecipe
//
//  Created by 石田 光一 on 10/05/23.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ChapterTwo.h"

@interface IPhoneSDKRecipeViewController : UIViewController {
	IBOutlet UIButton *copyButton;
}

@property (nonatomic, retain) UIButton *copyButton;

//- (IBAction) copyIamge;

@end

