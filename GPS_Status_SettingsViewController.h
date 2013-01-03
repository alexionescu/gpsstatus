//
//  GPS_Status_SettingsViewController.h
//  GPS Status!
//
//  Created by Alex Ionescu on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GPS_Status_SettingsViewControllerDelegate;

@interface GPS_Status_SettingsViewController : UIViewController
@property (nonatomic, assign) id<GPS_Status_SettingsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@protocol GPS_Status_SettingsViewControllerDelegate
- (void)settingsViewDoneButtonPressed:(GPS_Status_SettingsViewController *)viewController;
@end
