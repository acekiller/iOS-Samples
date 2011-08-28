//
//  ChapterTwo.h
//  IPhoneSDKRecipe
//
//  Created by 石田 光一 on 10/05/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SAMPLEDATA_KEY_STARS (@"stars")
#define SAMPLEDATA_KEY_TITLE (@"title")
#define SAMPLEDATA_KEY_ITEMS (@"items")


@interface ChapterTwo : NSObject {
	int starCount;
	NSString *titleText;
	NSMutableDictionary *items;
	int tempNumber; // 保存しない変数
}

@property (nonatomic, retain) int starCount;
@property (nonatomic, retain, readwrite) NSString *titleText;
@property (nonatomic, retain, readwrite) NSMutableDictionary *items;
@property (nonatomic, readwrite) int tempNumber;

+ (NSString *)uniqueFileNameWithExtention:(NSString *)ext;
+ (void)URLEncodingTest;
+ (void)NSArrayRandamizedResult;

@end

@interface NSArray (randomized)
-(NSArray*)randomizedArray;
@end
