/*
     File: AppDelegate.m
 Abstract: The application delegate class
  Version: 1.3
 
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

#import "AppDelegate.h"

NSString *kFirstNameKey			= @"firstNameKey";
NSString *kLastNameKey			= @"lastNameKey";
NSString *kNameColorKey			= @"nameColorKey";
NSString *kBackgroundColorKey	= @"backgroundColorKey";


@implementation AppDelegate

@synthesize window, navigationController, firstName, lastName, backgroundColor, textColor;

- (void)dealloc
{
	[navigationController release];
	[firstName release];
	[lastName release];
	[window release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[window addSubview:[navigationController view]];
	
	NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kFirstNameKey];
	if (testValue == nil)
	{
		// no default values have been set, create them here based on what's in our Settings bundle info
		//
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];

		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];

		NSString *firstNameDefault;
		NSString *lastNameDefault;
		NSNumber *nameColorDefault;
		NSNumber *backgroundColorDefault;
		
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray)
		{
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			
			if ([keyValueStr isEqualToString:kFirstNameKey])
			{
				firstNameDefault = defaultValue;
			}
			else if ([keyValueStr isEqualToString:kLastNameKey])
			{
				lastNameDefault = defaultValue;
			}
			else if ([keyValueStr isEqualToString:kNameColorKey])
			{
				nameColorDefault = defaultValue;
			}
			else if ([keyValueStr isEqualToString:kBackgroundColorKey])
			{
				backgroundColorDefault = defaultValue;
			}
		}

		// since no default values have been set (i.e. no preferences file created), create it here		
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
										firstNameDefault, kFirstNameKey,
										lastNameDefault, kLastNameKey,
										nameColorDefault, kNameColorKey,
										backgroundColorDefault, kBackgroundColorKey,
									  nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	// we're ready to do, so lastly set the key preference values
	firstName = [[NSUserDefaults standardUserDefaults] stringForKey:kFirstNameKey];
	lastName = [[NSUserDefaults standardUserDefaults] stringForKey:kLastNameKey];
	textColor = [[NSUserDefaults standardUserDefaults] integerForKey:kNameColorKey];
	backgroundColor = [[NSUserDefaults standardUserDefaults] integerForKey:kBackgroundColorKey];
}

@end
