WeatherMap

===========================================================================
ABSTRACT
Demonstrates the use of the MapKit framework, displaying a map view with custom MKAnnotationViews.  An annotation object on a map is any object that conforms to the MKAnnotation protocol and is displayed on the screen as a MKAnnotationView.  Through the use of the MKAnnotation protocol and MKAnnotationView, this application identifies four major cities in North America with fictitious weather information.

===========================================================================
DISCUSSION

These cities and their weather data are stored on disk using Core Data.  Maps can potentially have dozens or hundreds of annotations, which is why the use of Core Data is demonstrated here.  Core Data is a rich and sophisticated object graph management framework capable of dealing with large volumes of data.

Important:
The MapKit framework uses Google services to provide map data. Use of this class and the associated interfaces binds you to the Google Maps/Google Earth API terms of service. You can find these terms of service mentioned in the header section of "MKMapView.h".

===========================================================================
SYSTEM REQUIREMENTS

iPhone OS 3.0

===========================================================================
PACKAGING LIST

AppDelegate
Configures and displays the application window and navigation controller.

MapViewController
Controls the MKMapView and leverages the WeatherServer class to display each weather location.

WeatherAnnotationView
The UIView or MKAnnotationView for drawing each weather location's data.

WeatherItem
The weather object representing each location on the map.

WeatherServer
Manages and serves all weather locations backed by Core Data.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS

1.0 Initial version published.

===========================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.
