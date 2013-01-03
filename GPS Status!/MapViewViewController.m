//
//  MapViewViewController.m
//  GPS Status!
//
//  Created by Alex Ionescu on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewViewController.h"

@interface MapViewViewController ()
@property (nonatomic, strong) NSTimer *_timer;
@end

@implementation MapViewViewController
@synthesize mapView = _mapView;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[self mapView] setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    return nil;
}

@end
