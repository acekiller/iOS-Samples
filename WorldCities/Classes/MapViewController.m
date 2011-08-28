/*
     File: MapViewController.m
 Abstract: Controls the map view, sets the map type, and sets the region according to the selected worldCity.
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
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "MapViewController.h"
#import "WorldCity.h"

@implementation MapViewController

@synthesize mapView;

- (WorldCitiesListController *)worldCitiesListController
{
    if (worldCitiesListController == nil)
    {
        worldCitiesListController = [[WorldCitiesListController alloc] initWithStyle:UITableViewStylePlain];
        worldCitiesListController.delegate = self;
        worldCitiesListController.title = @"Choose a city:";
    }
    return worldCitiesListController;
}

- (UINavigationController *)worldCitiesListNavigationController
{
    if (worldCitiesListNavigationController == nil)
    {
        worldCitiesListNavigationController = [[UINavigationController alloc] initWithRootViewController:self.worldCitiesListController];
    }
    return worldCitiesListNavigationController;
}

- (void)viewDidUnload
{
	self.mapView = nil;
}

- (void)dealloc
{
    [mapView release];
    [worldCitiesListController release];
    [worldCitiesListNavigationController release];

    [super dealloc];
}

- (IBAction)viewPlacesList
{
    [self.navigationController presentModalViewController:self.worldCitiesListNavigationController animated:YES];
}

- (IBAction)setMapType:(id)sender
{
    switch (((UISegmentedControl *)sender).selectedSegmentIndex)
    {
        case 0:
        {
            mapView.mapType = MKMapTypeStandard;
            break;
        } 
        case 1:
        {
            mapView.mapType = MKMapTypeSatellite;
            break;
        } 
        default:
        {
            mapView.mapType = MKMapTypeHybrid;
            break;
        } 
    }
}

- (void)animateToWorld:(WorldCity *)worldCity
{    
    MKCoordinateRegion current = mapView.region;
    MKCoordinateRegion zoomOut = { { (current.center.latitude + worldCity.coordinate.latitude)/2.0 , (current.center.longitude + worldCity.coordinate.longitude)/2.0 }, {90, 90} };
    [mapView setRegion:zoomOut animated:YES];
}

- (void)animateToPlace:(WorldCity *)worldCity
{
    MKCoordinateRegion region;
    region.center = worldCity.coordinate;
    MKCoordinateSpan span = {0.4, 0.4};
    region.span = span;
    [mapView setRegion:region animated:YES];
}

- (void)worldCitiesListController:(WorldCitiesListController *)controller didChooseWorldCity:(WorldCity *)aPlace
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    self.title = aPlace.name;
    MKCoordinateRegion current = mapView.region;
    if (current.span.latitudeDelta < 10)
    {
        [self performSelector:@selector(animateToWorld:) withObject:aPlace afterDelay:0.3];
        [self performSelector:@selector(animateToPlace:) withObject:aPlace afterDelay:1.7];        
    }
    else
    {
        [self performSelector:@selector(animateToPlace:) withObject:aPlace afterDelay:0.3];        
    }
}

@end

