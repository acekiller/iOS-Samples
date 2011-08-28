//
//  MemoryLeakViewController.m
//  MemoryLeak
//
//  Created by 石田 光一 on 10/05/19.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MemoryLeakViewController.h"

@implementation MemoryLeakViewController

int count;

-(NSString *)getCount
{
	NSString *result;
	count++;
	result = [[NSString alloc] initWithFormat:@"Count up to %d", count];
	return result;
}

-(void)leakJob
{
	NSLog(@"%@", [self getCount]);
}

-(void)loopSub1
{
	long count = 0;
	for(long i = 0.0; i < 10000.0; i++)
	{
		count += i;
	}
}

- (void)loopSub2
{
	long count = 0;
	for(long i = 0; i < 20000; i++)
	{
		count += i;
	}
}

- (void)loopJob2
{
	[self loopSub1];
	[self loopSub2];
}

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
	
	count = 0;
	[NSTimer scheduledTimerWithTimeInterval:0.5
																	 target:self
																 selector:@selector(loopJob2)
																 userInfo:nil
																	repeats:YES];
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
