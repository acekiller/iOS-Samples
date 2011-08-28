/*
     File: DataController.m
 Abstract: A simple controller class responsible for managing the application's data.
 Typically this object would be able to load and save a file containing the appliction's data. This example illustrates just the basic minimum: it creates an array containing information about some plays and provides simple accessor methods for the array and its contents.
  Version: 2.7
 
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

#import "DataController.h"
#import "Play.h"


@interface DataController ()
@property (nonatomic, copy, readwrite) NSMutableArray *list;
- (void)createDemoData;
@end


@implementation DataController

@synthesize list;


- (id)init {
    if (self = [super init]) {
        [self createDemoData];
    }
    return self;
}

// Custom set accessor to ensure the new list is mutable
- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        [list release];
        list = [newList mutableCopy];
    }
}

// Accessor methods for list
- (unsigned)countOfList {
    return [list count];
}

- (Play *)objectInListAtIndex:(unsigned)theIndex {
    return [list objectAtIndex:theIndex];
}


- (void)dealloc {
    [list release];
    [super dealloc];
}


- (void)createDemoData {
    
    /*
     Create an array containing some demonstration data.
     Each data item is a Play that contains information about a play -- its list of characters, its genre, and its year of publication.  Typically the data would be comprised of instances of custom classes rather than dictionaries, but using dictionaries means fewer distractions in the example.
     */
    
    NSMutableArray *playList = [[NSMutableArray alloc] init];
    Play *play;
    NSArray *characters;
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
	play = [[Play alloc] init];
	play.title = @"Julius Caesar";
	play.genre = @"Tragegy";
	[dateComponents setYear:1599];
	play.date = [calendar dateFromComponents:dateComponents];
	characters = [[NSArray alloc] initWithObjects:@"Antony", @"Artemidorus", @"Brutus", @"Caesar", @"Calpurnia", @"Casca", @"Cassius", @"Cicero", @"Cinna", @"Cinna the Poet", @"Citizens", @"Claudius", @"Clitus", @"Dardanius", @"Decius Brutus", @"First Citizen", @"First Commoner", @"First Soldier", @"Flavius", @"Fourth Citizen", @"Lepidus", @"Ligarius", @"Lucilius", @"Lucius", @"Marullus", @"Messala", @"Messenger", @"Metellus Cimber", @"Octavius", @"Pindarus", @"Poet", @"Popilius", @"Portia", @"Publius", @"Second Citizen", @"Second Commoner", @"Second Soldier", @"Servant", @"Soothsayer", @"Strato", @"Third Citizen", @"Third Soldier", @"Tintinius", @"Trebonius", @"Varro", @"Volumnius", @"Young Cato", nil];
    play.characters = characters;
	[characters release];
	[playList addObject:play];
    [play release];
    
	play = [[Play alloc] init];
	play.title = @"King Lear";
	play.genre = @"Tragegy";
	[dateComponents setYear:1605];
	play.date = [calendar dateFromComponents:dateComponents];
    characters = [[NSArray alloc] initWithObjects:@"Captain", @"Cordelia", @"Curan", @"Doctor", @"Duke of Albany", @"Duke of Burgundy", @"Duke of Cornwall", @"Earl of Gloucester", @"Earl of Kent", @"Edgar", @"Edmund", @"Fool", @"Gentleman", @"Goneril", @"Herald", @"King of France", @"Knight", @"Lear", @"Messenger", @"Old Man", @"Oswald", @"Regan", @"Servant 1", @"Servant 2", @"Servant 3", nil];
    play.characters = characters;
	[characters release];
	[playList addObject:play];
    [play release];
    
	play = [[Play alloc] init];
	play.title = @"Othello";
	play.genre = @"Tragegy";
	[dateComponents setYear:1604];
	play.date = [calendar dateFromComponents:dateComponents];
    characters = [[NSArray alloc] initWithObjects:@"Bianca", @"Brabantio", @"Cassio", @"Clown", @"Desdemona", @"Duke of Venice", @"Emilia", @"First Gentleman", @"First Musician", @"First Officer", @"First Senator", @"Fourth Gentleman", @"Gentleman", @"Gratiano", @"Herald", @"Iago", @"Lodovico, Kinsman to Brabantio", @"Messenger", @"Montano", @"Othello", @"Roderigo", @"Sailor", @"Second Gentleman", @"Second Senator", @"Third Gentleman", nil];
    play.characters = characters;
	[characters release];
	[playList addObject:play];
    [play release];
    
	play = [[Play alloc] init];
	play.title = @"Henry IV, Pt 1";
	play.genre = @"History";
    [dateComponents setYear:1597];
	play.date = [calendar dateFromComponents:dateComponents];
    characters = [[NSArray alloc] initWithObjects:@"Archbishop Scroop", @"Blunt", @"Carrier", @"Chamberlain", @"Earl of Douglas", @"Earl of Northumberland", @"Earl of Westmoreland", @"Earl of Worcester", @"Edward Poins", @"Falstaff", @"First Carrier", @"First Traveller", @"Francis", @"Gadshill", @"Glendower", @"Henry IV", @"Henry V", @"Hostess Quickly", @"Hotspur (Henry Percy)", @"Lady Percy", @"Lord Bardolph", @"Messenger", @"Mortimer", @"Ostler", @"Peto", @"Prince John, of Lancaster", @"Second Carrier", @"Servant", @"Sheriff", @"Sir Michael", @"Vernon", @"Vintner", nil];
    play.characters = characters;
	[characters release];
	[playList addObject:play];
    [play release];
    
	play = [[Play alloc] init];
	play.title = @"The Tempest";
	play.genre = @"Comedy";
    [dateComponents setYear:1611];
	play.date = [calendar dateFromComponents:dateComponents];
    characters = [[NSArray alloc] initWithObjects:@"Adrian", @"Alonso", @"Antonio", @"Ariel", @"Boatswain", @"Caliban", @"Ceres", @"Ferdinand", @"Francisco", @"Gonzalo", @"Iris", @"Juno", @"Master", @"Miranda", @"Prospero", @"Sebastian", @"Stephano", @"Trinculo", nil];
    play.characters = characters;
	[characters release];
	[playList addObject:play];
    [play release];
    
    self.list = playList;
    [playList release];
    [dateComponents release];
    [calendar release];
}

@end
