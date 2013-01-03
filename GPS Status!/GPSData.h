//
//  GPSData.h
//  GPS Status!
//
//  Created by Alex Ionescu on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "TableElement.h"

@interface GPSData : NSObject<CLLocationManagerDelegate, UITableViewDataSource>

- (void)turnGPSon:(BOOL)value;
- (NSString *)getAltitude;
- (NSString *)getLatitude;
- (NSString *)getLongitude;
- (NSString *)getPositionAccuracy;
- (NSString *)getAltitudeAccuracy;
@end
