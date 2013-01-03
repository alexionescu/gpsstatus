//
//  GPS_Status_ViewController.m
//  GPS Status!
//
//  Created by Alex Ionescu on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPS_Status_ViewController.h"

@interface GPS_Status_ViewController()
@property (nonatomic, strong) GPSData *gpsData;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation GPS_Status_ViewController
@synthesize uiTable = _uiTable;
@synthesize mapView = _mapView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    _gpsData = [[GPSData alloc] init];
    [[self uiTable] setDataSource:_gpsData];
    [[self mapView] setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [_gpsData turnGPSon:YES];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[GPS_Status_ViewController instanceMethodSignatureForSelector:@selector(updateTable)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(updateTable)];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.25 invocation:invocation repeats:YES];
}

- (void)viewDidUnload
{
    [self setUiTable:nil];
    [self setMapView:nil];
    [_timer invalidate];
    _timer = nil;
    _gpsData = nil;
    [super viewDidUnload];
}

- (void)updateTable
{
    [[self uiTable] reloadData];
}

- (IBAction)shareButtonPressed:(UIBarButtonItem *)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"SMS", nil, nil];
    
    [sheet showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark UIActionSheetDeleage methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
            [mailVC setMailComposeDelegate:self];
            [mailVC setSubject:@"My GPS Status!"];
            NSString *text = [NSString stringWithFormat:@"Latitude: %@\nLongitude: %@\nAltitude: %@\nAccuracy (Position): %@\nAccuracy (Altitude): %@\n",
                              [[self gpsData] getLatitude], [[self gpsData] getLongitude], [[self gpsData] getAltitude], [[self gpsData] getPositionAccuracy], [[self gpsData] getAltitudeAccuracy]];
            [mailVC setMessageBody:text isHTML:NO];
            
            [self presentModalViewController:mailVC animated:YES];
        }
    }
    if(buttonIndex == 1)
        NSLog(@"index 1");
    if(buttonIndex == 2)
        NSLog(@"index 2");
}

#pragma mark MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
@end