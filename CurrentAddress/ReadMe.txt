Current Address

===========================================================================
ABSTRACT

Demonstrates basic use of MapKit, displaying a map view and setting its region to current location.

It makes use of the MKReverseGeocoder class that provides services for converting your map coordinate (specified as a latitude/longitude pair) into information about that coordinate, such as the country, city, or street. A reverse geocoder object is a single-shot object that works with a network-based map service to look up placemark information for its specified coordinate value.  To use placemark information is leverages the MKPlacemark class to store this information.

Important:
The MapKit framework uses Google services to provide map data. Use of this class and the associated interfaces binds you to the Google Maps/Google Earth API terms of service. You can find these terms of service mentioned in the header section of "MKMapView.h".

===========================================================================
DISCUSSION

The MapViewController class and MapViewController.xib encapsulate all the interactions with the map view. These files are a good place to start to see how to set the region and map type of an MKMapView object. 

===========================================================================
SYSTEM REQUIREMENTS

iPhone OS 3.0

===========================================================================
PACKAGING LIST

AppDelegate
Configures the Core Data persistence stack and displays the application window.

MapViewController
Controls the map view, sets the map type, and sets the region according to the selected place.

WorldCitiesListController
Displays the list of WorldCities and allows them to be added, edited, and selected for display in the map view.

WorldCities
Contains the data for a world city object.

WorldCityEditingController
Used for adding and editing world cities.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS

1.0 Initial version published.

===========================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.
