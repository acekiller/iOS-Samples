//
//  ChapterTwo.m
//  IPhoneSDKRecipe
//
//  Created by 石田 光一 on 10/05/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChapterTwo.h"


@implementation ChapterTwo

+ (NSString *)uniqueFileNameWithExtention:(NSString *)ext
{
	// CFUUIDクラスのメソッド
	CFUUIDRef uudiRef = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uudiRef);
	CFRelease(uudiRef);
	
	NSString *fileName = [NSString stringWithFormat:@"%@.%@", uuidStr, ext];
	
	return fileName;
	
}

+ (void)URLEncodingTest
{
	NSString *originalString = @"URLエンコードする文字列&";
	NSString *encode1 = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																		  (CFStringRef)originalString,
																		  NULL,
																		  CFSTR(";,/?:@&=+$#"),
																		  kCFStringEncodingUTF8);
	NSString *encode2 = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																		  (CFStringRef)originalString,
																		  NULL,
																		  NULL,
																		  kCFStringEncodingUTF8);
	
	NSLog(@"original: %@", originalString);
	NSLog(@"enoded1: %@", encode1);
	NSLog(@"enoded2: %@", encode2);

}

+ (void)NSArrayRandamizedResult
{
	srand(time(NULL));
	NSArray *array = [NSArray arrayWithObjects:@"str1", @"str2", @"str3", @"str4", nil];
	NSLog(@"randomize: %@", [array randomizedArray]);
}

- (void)encodeWithCorder:(NSCoder*)coder
{
	// エンコード
	[coder encodeObject:titleText
				 forKey:SAMPLEDATA_KEY_TITLE];
	[coder encodeObject:imtes
				 forKey:SAMPLEDATA_KEY_ITEMS];
	[coder encodeObject:starCount
				 forKey:SAMPLEDATA_KEY_STARS];
}

@end

@implementation NSArray (randomized)

- (NSArray *)randomizedArray
{
	NSMutableArray *results = [NSMutableArray arrayWithArray:self];
	
	int i = [results count];
	while(--i > 0)
	{
		int j = rand() % (i+1);
		[results exchangeObjectAtIndex:i
					 withObjectAtIndex:j];
	}
	
	return [NSArray arrayWithArray:results];
}

@end
