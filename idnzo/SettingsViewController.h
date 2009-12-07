//
//  SettingsViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 12/6/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#include "TextFieldViewController.h"

@interface SettingsViewController : UITableViewController {
  UITableViewCell *switchCell;
  UISwitch *switchWidget;
  
  NSString *username;
  NSString *password;
}

@property (nonatomic, retain) UITableViewCell *switchCell;
@property (nonatomic, retain) UISwitch *switchWidget;
@property (nonatomic) BOOL isSyncEnabled;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (void) onClickSwitch:(id)sender;

- (BOOL) hasPassword;

@end
