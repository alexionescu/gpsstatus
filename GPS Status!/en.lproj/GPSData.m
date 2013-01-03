//
//  GPSData.m
//  GPS Status!
//
//  Created by Alex Ionescu on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPSData.h"

@interface GPSData()
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSNumberFormatter *format;

@end
@implementation GPSData
typedef enum
{
    LATITUDE, LONGITUDE
} POSITION_TYPE;
#pragma mark LAZY_INSTANTIATION
- (GPSData *)init
{
    self = [super init];
    if(self)
    {
        _data = [self data];
        _locationManager = [self locationManager];
        _locationManager.delegate = self;
        _defaults = [NSUserDefaults standardUserDefaults];
        _location = [[CLLocation alloc] initWithCoordinate:kCLLocationCoordinate2DInvalid altitude:-1 horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:[NSDate date]];
        _format = [[NSNumberFormatter alloc] init];
        [_format setNumberStyle:NSNumberFormatterDecimalStyle];
        [_format setMinimumFractionDigits:5];
        
    }
    
    return self;
}

- (NSMutableArray *)data
{
    if(!_data)
    {
        _data = [[NSMutableArray alloc] init];
        NSMutableArray *_statusArray = [[NSMutableArray alloc] init];
        [_statusArray addObject:NSLocalizedString(@"Status", nil)];
        [_statusArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"Signal", nil) withDetail:NSLocalizedString(@"Unavailable", nil)]];
        [[self data] addObject:_statusArray];

        NSMutableArray *_locationArray = [[NSMutableArray alloc] init];
        CLLocationCoordinate2D coord = kCLLocationCoordinate2DInvalid;
        [_locationArray addObject:NSLocalizedString(@"Location", nil)];
        [_locationArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"Latitude", nil) withDetail:[NSNumber numberWithDouble:coord.latitude]]];
        [_locationArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"Longitude", nil) withDetail:[NSNumber numberWithDouble:coord.longitude]]];
        [_locationArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"Altitude", nil) withDetail:[NSNumber numberWithDouble:-100000]]];
        [[self data] addObject:_locationArray];

        NSMutableArray *_accuracyArray = [[NSMutableArray alloc] init];
        [_accuracyArray addObject:NSLocalizedString(@"Accuracy", nil)];
        [_accuracyArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"Position", nil) withDetail:[NSNumber numberWithDouble:-1]]];
        [_accuracyArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"Altitude", nil) withDetail:[NSNumber numberWithDouble:-1]]];
        [[self data] addObject:_accuracyArray];

        NSMutableArray *_courseArray = [[NSMutableArray alloc] init];
        [_courseArray addObject:NSLocalizedString(@"Course", nil)];
        [_courseArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"Speed", nil) withDetail:[NSNumber numberWithDouble:-1]]];
        [_courseArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"True Heading", nil) withDetail:[NSNumber numberWithDouble:-1]]];
        [_courseArray addObject:[[TableElement alloc] initWithTitle:NSLocalizedString(@"Magnetic Heading", nil) withDetail:[NSNumber numberWithDouble:-1]]];
        [[self data] addObject:_courseArray];
    }
    return _data;
}

- (NSString *)getAccuracy
{
    return [[[[self data] objectAtIndex:0] objectAtIndex:1] detail];
}

- (NSString *)formatPosition:(NSString *)det ofType:(POSITION_TYPE)type
{
    NSString *_coordinatesSetting = [_defaults objectForKey:@"coordinates"];
    //NSString *det = [[[[self data] objectAtIndex:1] objectAtIndex:1] detail];

    if(_location.coordinate.longitude == kCLLocationCoordinate2DInvalid.longitude || _location.coordinate.latitude == kCLLocationCoordinate2DInvalid.latitude || [det isEqualToString:NSLocalizedString(@"Unavailable", nil)])
        return NSLocalizedString(@"Unavailable", nil);
    
    double coord = [det doubleValue];
    if([_coordinatesSetting isEqualToString:@"Standard"])
    {
        //set the direction
        NSMutableString *ret = [NSMutableString stringWithFormat:@"%@", (coord > 0 && type == LATITUDE) ? @"N" : (coord < 0 && type == LATITUDE) ? @"S" : (coord > 0) ? @"E" : @"W"];
        
        //seperate the degrees from leftover
        NSArray *coordSeperated = [det componentsSeparatedByString:@"."];
        
        //remove negative sign and add space
        [ret appendString:[[coordSeperated objectAtIndex: 0] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        [ret appendString:@" "];
        double needToFormat = [[NSString stringWithFormat:@".%@", [coordSeperated objectAtIndex:1]] doubleValue] * 60;
        
        [ret appendString:[_format stringFromNumber:[NSNumber numberWithDouble:needToFormat]]];
        
        return [NSString stringWithFormat:@"%@", ret];
    }
    if([_coordinatesSetting isEqualToString:@"Deg/Min/Sec"])
    {
        NSArray *coordSeperated = [det componentsSeparatedByString:@"."];
        int deg = (int)[[coordSeperated objectAtIndex:0] doubleValue];
        double minD = [[NSString stringWithFormat:@".%@", [coordSeperated objectAtIndex:1]] doubleValue] * 60;
        coordSeperated = [[NSString stringWithFormat:@"%f", minD] componentsSeparatedByString:@"."];
        int min = minD;
        double sec = [[NSString stringWithFormat:@".%@", [coordSeperated objectAtIndex:1]] doubleValue] * 60;
        NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
        [format setNumberStyle:NSNumberFormatterDecimalStyle];
        [format setMinimumFractionDigits:5];
        
        return [NSString stringWithFormat:@"%i° %i' %@'", deg, min, [_format stringFromNumber:[NSNumber numberWithDouble:sec]]];;
    }
    if([_coordinatesSetting isEqualToString:@"WGS84"])
    {
        NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
        [format setNumberStyle:NSNumberFormatterDecimalStyle];
        [format setMinimumFractionDigits:5];
        return [_format stringFromNumber:[NSNumber numberWithDouble:coord]];
    }
    return @"";
}

- (NSString *)formatDistance:(NSString *)det allowNegativeValues:(BOOL)allowNeg
{
    NSString *_distanceSetting = [_defaults objectForKey:@"distance"];
    double num = [det doubleValue];
    if(num < 0 && !allowNeg)
    {
      return NSLocalizedString(@"Unavailable", nil);
    }
    if([_distanceSetting isEqualToString:@"Feet"])
    {
        num *= 3.281;
        return [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_distanceSetting, nil)];
    }
    if([_distanceSetting isEqualToString:@"Meters"])
        return [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_distanceSetting, nil)];
    
    return @"";
}

- (NSString *)formatSpeed:(NSString *)det
{
    NSString *_speedSetting = [_defaults objectForKey:@"speed"];
    double num = [det doubleValue];
    if(num < 0)
        return NSLocalizedString(@"Unavailable", nil);
    if([_speedSetting isEqualToString:@"mi/hr"])
    {
        num *= 2.237;
        return [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_speedSetting, nil)];
    }
    
    if([_speedSetting isEqualToString:@"km/hr"])
    {
        num *= 3.6;
        return [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_speedSetting, nil)];
    }
    
    if([_speedSetting isEqualToString:@"m/s"])
        return [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_speedSetting, nil)];
    return @"";
}
- (NSString *)getLatitude
{
    //NSLog([[[[self data] objectAtIndex:1] objectAtIndex:1] description]);
    //return [[[[self data] objectAtIndex:1] objectAtIndex:1] detail];
    return [self formatPosition:[[[[self data] objectAtIndex:1] objectAtIndex:1] detail] ofType:LATITUDE];
}
- (NSString *)getLongitude
{
    //return [[[[self data] objectAtIndex:1] objectAtIndex:2] detail];
    return [self formatPosition:[[[[self data] objectAtIndex:1] objectAtIndex:2] detail] ofType:LONGITUDE];
}
- (NSString *)getAltitude
{
    return [self formatDistance:[[[[self data] objectAtIndex:1] objectAtIndex:3] detail] allowNegativeValues:YES];
}

- (NSString *)getPositionAccuracy
{
    return [self formatDistance:[[[[self data] objectAtIndex:2] objectAtIndex:1] detail] allowNegativeValues:NO];
}

- (NSString *)getAltitudeAccuracy
{
    return [self formatDistance:[[[[self data] objectAtIndex:2] objectAtIndex:2] detail] allowNegativeValues:NO];
}

#pragma mark CLLocationManagerDelegate METHODS
- (CLLocationManager *)locationManager
{
    if(!_locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    _location = newLocation;
    double acc = _location.horizontalAccuracy;
    [[[[self data] objectAtIndex:0] objectAtIndex:1] setDetail:(acc < 0 || acc >= 5000) ? NSLocalizedString(@"Unavailable", nil) :
                                                                                 (acc >= 1000 && acc < 5000) ? NSLocalizedString(@"Bad", nil) :
                                                                                 (acc >= 200 && acc < 1000) ? NSLocalizedString(@"Poor", nil) :
                                                                                 (acc >= 50 && acc < 200) ? NSLocalizedString(@"Fair", nil) :
                                                                                 (acc >= 30 && acc < 50) ? NSLocalizedString(@"Good", nil) :
                                                                                 NSLocalizedString(@"Excellent", nil)];
   
    [[[[self data] objectAtIndex:1] objectAtIndex:1] setDetail:[NSNumber numberWithDouble:newLocation.coordinate.latitude]];
    [[[[self data] objectAtIndex:1] objectAtIndex:2] setDetail:[NSNumber numberWithDouble:newLocation.coordinate.longitude]];
    [[[[self data] objectAtIndex:1] objectAtIndex:3] setDetail:[NSNumber numberWithDouble:newLocation.altitude]];

    [[[[self data] objectAtIndex:2] objectAtIndex:1] setDetail:[NSNumber numberWithDouble:newLocation.horizontalAccuracy]];
    [[[[self data] objectAtIndex:2] objectAtIndex:2] setDetail:[NSNumber numberWithDouble:newLocation.verticalAccuracy]];

    [[[[self data] objectAtIndex:3] objectAtIndex:1] setDetail:[NSNumber numberWithDouble:newLocation.speed]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [[[[self data] objectAtIndex:3] objectAtIndex:2] setDetail:[NSNumber numberWithDouble:newHeading.trueHeading]];
    [[[[self data] objectAtIndex:3] objectAtIndex:3] setDetail:[NSNumber numberWithDouble:newHeading.magneticHeading]];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[[[self data] objectAtIndex:0] objectAtIndex:1] setDetail:NSLocalizedString(@"Unavailable", nil)];
    if(error.code == kCLErrorDenied)
    {
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"GPS Status! needs location services to be on in order to operate.", nil) delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
    }
    if(error.code == kCLErrorNetwork)
    {
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil) message: NSLocalizedString(@"GPS Status! needs the device to be connected to a network to operate.", nil) delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark UITableViewDataSource METHODS
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self data] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self data] objectAtIndex:section] objectAtIndex:0];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0)
    {
        NSTimeInterval delta = -[_location.timestamp timeIntervalSinceNow];
        unsigned int min = (int)delta / 60;
        unsigned int sec = (int)delta % 60;
        return [NSString stringWithFormat:@"%@: %02d:%02d", NSLocalizedString(@"Last Update", nil), min, sec];
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self data] objectAtIndex:section] count] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *_coordinatesSetting = [_defaults objectForKey:@"coordinates"];
    //NSString *_speedSetting = [_defaults objectForKey:@"speed"];
    //NSString *_distanceSetting = [_defaults objectForKey:@"distance"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
    
    cell.textLabel.text = [[[[self data] objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row + 1)] title];

    NSString *det = [[[[[self data] objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row + 1)] detail] description];

    //signal
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        NSString *acc =  [[[[self data] objectAtIndex:0] objectAtIndex:1] detail];
        cell.detailTextLabel.text = acc;
        if([acc isEqualToString:NSLocalizedString(@"Unavailable", nil)])
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signalbars0.png"]];
        else if([acc isEqualToString:NSLocalizedString(@"Bad", nil)])
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signalbars1.png"]];
        else if([acc isEqualToString:NSLocalizedString(@"Poor", nil)])
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signalbars2.png"]];
        else if ([acc isEqualToString:NSLocalizedString(@"Fair", nil)])
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signalbars3.png"]];
        else if([acc isEqualToString:NSLocalizedString(@"Good", nil)])
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signalbars4.png"]];
        else
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signalbars5.png"]];
        return cell;
        
    }

    cell.accessoryView = nil;
    //coordinate conversions
    if(indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1))
    {
        cell.detailTextLabel.text = [self formatPosition:det ofType:indexPath.row ? LONGITUDE : LATITUDE];
        return cell;
        /*//invalid coordinate we are done
        if(_location.coordinate.longitude == kCLLocationCoordinate2DInvalid.longitude || _location.coordinate.latitude == kCLLocationCoordinate2DInvalid.latitude)
        {
            cell.detailTextLabel.text = NSLocalizedString(@"Unavailable", nil);
            return cell;
        }
        
        double coord = [det doubleValue];
        if([_coordinatesSetting isEqualToString:@"Standard"])
        {
            //set the direction
            NSMutableString *ret = [NSMutableString stringWithFormat:@"%@", (coord > 0 && indexPath.row == 0) ? @"N" : (coord < 0 && indexPath.row == 0) ? @"S" : (coord > 0 && indexPath.row == 1) ? @"E" : @"W"];

            //seperate the degrees from leftover
            NSArray *coordSeperated = [det componentsSeparatedByString:@"."];

            //remove negative sign and add space
            [ret appendString:[[coordSeperated objectAtIndex: 0] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            [ret appendString:@" "];
            double needToFormat = [[NSString stringWithFormat:@".%@", [coordSeperated objectAtIndex:1]] doubleValue] * 60;

            [ret appendString:[_format stringFromNumber:[NSNumber numberWithDouble:needToFormat]]];
            
            cell.detailTextLabel.text = ret;
            return cell;
        }
        if([_coordinatesSetting isEqualToString:@"Deg/Min/Sec"])
        {
            NSArray *coordSeperated = [det componentsSeparatedByString:@"."];
            int deg = (int)[[coordSeperated objectAtIndex:0] doubleValue];
            double minD = [[NSString stringWithFormat:@".%@", [coordSeperated objectAtIndex:1]] doubleValue] * 60;
            coordSeperated = [[NSString stringWithFormat:@"%f", minD] componentsSeparatedByString:@"."];
            int min = minD;
            double sec = [[NSString stringWithFormat:@".%@", [coordSeperated objectAtIndex:1]] doubleValue] * 60;
            NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
            [format setNumberStyle:NSNumberFormatterDecimalStyle];
            [format setMinimumFractionDigits:5];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i° %i' %@'", deg, min, [_format stringFromNumber:[NSNumber numberWithDouble:sec]]];
            return cell;
        }
        if([_coordinatesSetting isEqualToString:@"WGS84"])
        {
            NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
            [format setNumberStyle:NSNumberFormatterDecimalStyle];
            [format setMinimumFractionDigits:5];
            cell.detailTextLabel.text = [_format stringFromNumber:[NSNumber numberWithDouble:coord]];
            return cell;
        }*/

    }

    //distance conversions
    if((indexPath.section == 1 && indexPath.row == 2) || indexPath.section == 2)
    {
        cell.detailTextLabel.text = [self formatDistance:det allowNegativeValues:(indexPath.section == 1) ? YES: NO];
        return cell;
        /*double num = [det doubleValue];
        if((num < 0 && indexPath.section != 1) || (indexPath.section == 1 && num == -100000))
        {
            cell.detailTextLabel.text = NSLocalizedString(@"Unavailable", nil);
            return cell;
        }
        if([_distanceSetting isEqualToString:@"Feet"])
        {
            num *= 3.281;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_distanceSetting, nil)];
            return cell;
        }
        if([_distanceSetting isEqualToString:@"Meters"])
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_distanceSetting, nil)];
            return cell;
        }*/
    }

    //speed conversions
    if(indexPath.section == 3 && indexPath.row == 0)
    {
        cell.detailTextLabel.text = [self formatSpeed:det];
        return cell;
        /*double num = [det doubleValue];
        if(num < 0)
        {
            cell.detailTextLabel.text = NSLocalizedString(@"Unavailable", nil);
            return cell;
        }
        if([_speedSetting isEqualToString:@"mi/hr"])
        {
            num *= 2.237;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_speedSetting, nil)];
            return cell;
        }

        if([_speedSetting isEqualToString:@"km/hr"])
        {
            num *= 3.6;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_speedSetting, nil)];
            return cell;
        }

        if([_speedSetting isEqualToString:@"m/s"])
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [_format stringFromNumber:[NSNumber numberWithDouble:num]], NSLocalizedString(_speedSetting, nil)];
            return cell;
        }*/
    }

    //compass
    if(indexPath.section == 3 && (indexPath.row == 1 || indexPath.row == 2))
    {
        double num = [det doubleValue];
        if(num < 0)
        {
            cell.detailTextLabel.text = NSLocalizedString(@"Unavailable", nil);
            return cell;
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", [_format stringFromNumber:[NSNumber numberWithDouble: num]], @"°"];
        return cell;
    }
    

    return cell;
}

#pragma mark OTHER
- (void)turnGPSon:(BOOL)value
{
    if(value)
    {
        [[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
        [[self locationManager] startUpdatingLocation];
        [[self locationManager] startUpdatingHeading];

    }
    else
    {
        [[self locationManager] stopUpdatingLocation];
        [[self locationManager] stopUpdatingHeading];
    }
}


#pragma mark DESTRUCTOR
- (void)dealloc
{
    _data = nil;
    _locationManager = nil;
    _location = nil;
    _defaults = nil;
    _format = nil;
}

@end

