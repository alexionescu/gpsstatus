//
//  GPS_Status_ViewController.h
//  GPS Status!
//
//  Created by Alex Ionescu on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPSData.h"
#import "MapViewViewController.h"
#import <MessageUI/MessageUI.h>

@interface GPS_Status_ViewController : UIViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *uiTable;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end
