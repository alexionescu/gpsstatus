//
//  GPS_Status_SettingsViewController.m
//  GPS Status!
//
//  Created by Alex Ionescu on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPS_Status_SettingsViewController.h"

@interface GPS_Status_SettingsViewController ()

@end

@implementation GPS_Status_SettingsViewController

@synthesize delegate = _delegate;
@synthesize doneButton = _doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender
{
    [self.delegate settingsViewDoneButtonPressed:self];
    self.delegate = nil;
    [self dismissModalViewControllerAnimated:YES];
}

@end
