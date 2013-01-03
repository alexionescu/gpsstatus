//
//  MapViewViewController.h
//  GPS Status!
//
//  Created by Alex Ionescu on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GPSData.h"

@interface MapViewViewController : UIViewController<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end
