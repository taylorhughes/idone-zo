//
//  SettingsViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 12/6/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#include "TextFieldViewController.h"
#include "DNZOAppDelegate.h"
#include "SettingsHelper.h"

@interface SettingsViewController : UITableViewController {
  UITableViewCell *switchCell;
  UISwitch *switchWidget;
  
  NSString *username;
  UIView *longOperationDialogView;
  UILabel *longOperationLabel;
}

@property (nonatomic, retain) UITableViewCell *switchCell;
@property (nonatomic, retain) UISwitch *switchWidget;
@property (nonatomic) BOOL isSyncEnabled;
@property (nonatomic, retain) IBOutlet UIView *longOperationDialogView;
@property (nonatomic, retain) IBOutlet UILabel *longOperationLabel;

@property (nonatomic, copy) NSString *username;

+ (SettingsViewController*) settingsViewControllerWithSyncEnabled;
+ (SettingsViewController*) settingsViewController;

- (void) onClickSwitch:(id)sender;

@end
