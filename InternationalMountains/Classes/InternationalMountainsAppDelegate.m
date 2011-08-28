/*
     File: InternationalMountainsAppDelegate.m
 Abstract: Application delegate class implementation
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

#import "InternationalMountainsAppDelegate.h"
#import "RootViewController.h"

/* key name for the application preference in our Settings.bundle */
NSString *kSettingKey = @"sort";

/* Class extension for "private" methods */
@interface InternationalMountainsAppDelegate ()
- (BOOL)getSortAppPref; /* get the "sort" app pref value (on/off) */
@end

@implementation InternationalMountainsAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	/* Get the current "sort" application preference (creating if it
	   doesn't exist yet) and if enabled (the default), sort the mountain list */
	if ([self getSortAppPref]) {
		[rootViewController sortMountains];
	}	
	/* Set main window's view to be the navigationController's view,
	   which the navigationController will manage, and then show main window */
    [window addSubview:[navigationController view]];
	[window makeKeyAndVisible];	
}


- (void)dealloc {
	[navigationController release];
    [rootViewController release];
	[window release];
	[super dealloc];
}


#pragma mark --InternationalMountainsAppDelegate (private methods)--


- (BOOL)getSortAppPref {
	/* As this application provides a Settings.bundle for application
	   preferences, the following is a simple example that retrieves the
	   current user-set preferences. */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	/* Similar to the AppPrefs sample, we first test to see if the preferences
	   settings exist, and create if needed. */
	NSData *testValue = [defaults dataForKey:kSettingKey]; /* setting exists? */
	if (testValue == nil) {
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
		NSNumber *settingDefault;
		NSDictionary *prefItem;
		
		for (prefItem in prefSpecifierArray) {
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			
			if ([keyValueStr isEqualToString:kSettingKey]) {
				settingDefault = defaultValue;
			}
		}
		
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
									 settingDefault, kSettingKey, nil];		
		[defaults registerDefaults:appDefaults];
		[defaults synchronize];
	}
	return [defaults boolForKey:kSettingKey];
}


@end
