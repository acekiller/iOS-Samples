//
//  IPhoneSDKRecipeViewController.m
//  IPhoneSDKRecipe
//
//  Created by 石田 光一 on 10/05/23.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "IPhoneSDKRecipeViewController.h"

@implementation IPhoneSDKRecipeViewController

@synthesize copyButton;

/*
- (IBAction) copyIamge
{
	UIImage *image = [UIImage imageNamed:@"image.png"];
	
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	
	// アプリケーション終了後もコピーした内容を残す
	pasteBoard.persistent = YES;
	
	// データのフォーマットについて
	
	// PNG形式とJPEG形式でクリップボードにコピー
	NSMutableDictionary *item = [NSMutableDictionary dictionaryWithCapacity:2];
	[item setValue:UIImagePNGRepresentation(image)
			forKey:(NSString*)kUTTypePNG];
	[item setValue:UIImageJPEGRepresentation(image, 0.9)
			forKey:(NSString*)kUTTypeJPEG];
	[pasteBoard setItems:[NSArray arrayWithObjects:item]];
}

- (void)pasteImageAsFile
{
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	
	if([pasteBoard containsPasteboardTypes:[NSArray arrayWithObject:(NSString *)kUTTypeJPEG]])
	{
		// JPEG
		NSData *data = [pasteBoard dataForPasteboardType:(NSString*)kUTTypeJPEG];
		UIImage *image = [UIImage imageWithData:data];
		
		// PNG
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"paste.png"];
		NSLog(@"%@", filePath);
		
		[UIImagePNGRepresentation(image) writeToFile:filePath
										  atomically:YES];
	}else if ([pasteBoard containsPasteboardTypes:[NSArray arrayWithObject:(NSString*)kUTTypePNG]]){
		// PNG
		NSData *data = [pasteBoard dataForPasteboardType:(NSString*)kUTTypePNG];
		UIImage *image = [UIImage imageWithData:data];
		
		// PNG形式で保存
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"paste.png"];
		NSLog(@"%@", filePath);
		
		[UIImagePNGRepresentation(image) writeToFile:filePath
										  atomically:YES];
	}
}
 */

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"%@", [ChapterTwo uniqueFileNameWithExtention:@"txt"]);
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
