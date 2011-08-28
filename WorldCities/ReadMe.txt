WorldCities

===========================================================================
ABSTRACT

"WorldCities" demonstrates basic use of MapKit, including displaying a map view and setting its region. A list of cities are stored in a plist file loaded at launch time.  Each city is represented by a "WorldCity" class which consists of a name, a latitude, and a longitude. The user can select from a pre-defined world cities. When a world cities is selected, the map view animates to a region with the coordinates of the world cities in the center of the view. The user can also choose between map types - Standard, Satellite, and Hybrid - using the segmented control in the toolbar of the main view.

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
Configures and displays the application window and navigation controller.

MapViewController
Controls the map view, sets the map type, and sets the region according to the selected place.

WorldCitiesListController
Displays the list of WorldCities to be selected for display in the map view.

cityList.plist
Contains the data for a world city object.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS

1.0 Initial version published.

===========================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.
