MapCallouts

===========================================================================
ABSTRACT

Demonstrates the use of the MapKit framework, displaying a map view with custom MKAnnotations each with custom callouts.  An annotation object on a map is any object that conforms to the MKAnnotation protocol and is displayed on the screen as a MKAnnotationView.  Through the use of the MKAnnotation protocol and MKAnnotationView, this application shows how you can extend annotations with custom strings and left/right calloutAccessoryViews.

===========================================================================
DISCUSSION

This sample implements two different variations of MKPinAnnotationViews each with their own specific information.  One shows how to use a rightCalloutAccessoryView with a UIButtonTypeDetailDisclosure button and other with leftCalloutAccessoryView containing an image.

Important:
The MapKit framework uses Google services to provide map data. Use of this class and the associated interfaces binds you to the Google Maps/Google Earth API terms of service. You can find these terms of service mentioned in the header section of "MKMapView.h".

===========================================================================
SYSTEM REQUIREMENTS

iPhone OS 3.0 or later

===========================================================================
PACKAGING LIST

AppDelegate
Configures and displays the application window and navigation controller.

MapViewController
The primary view controller containing the MKMapView, adding and removing both MKPinAnnotationViews through its toolbar.

BrideAnnotation
The custom MKAnnotation object representing the Golden Gate Bridge.

SFAnnotation
The custom MKAnnotation object representing the city of San Francisco.

DetailViewController
The detail view controller used for displaying the Golden Gate Bridge.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS

1.0 Initial version published.

===========================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.
