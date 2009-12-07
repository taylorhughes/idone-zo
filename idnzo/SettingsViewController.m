//
//  SettingsViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 12/6/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

@synthesize switchCell, switchWidget;

@synthesize username;
@synthesize password;

#define SYNC_ENABLED_KEY @"syncEnabled"
#define USERNAME_KEY @"username"
#define PASSWORD_KEY @"password"

- (UITableViewCell*)switchCell
{
  if (!switchCell)
  {
    self.switchCell = [[UITableViewCell alloc] init];
    [self.switchCell release];
    
    self.switchWidget = [[UISwitch alloc] init];
    [self.switchWidget release];
    
    CGFloat x = self.switchCell.frame.size.width - 120;
    self.switchWidget.frame = CGRectMake(x,9,0,0);
    [self.switchCell addSubview:self.switchWidget];
    
    [self.switchWidget addTarget:self 
                          action:@selector(onClickSwitch:) 
                forControlEvents:UIControlEventValueChanged];
  }
  return switchCell;
}
- (UISwitch *)switchWidget
{
  // Call this first to make sure it's instantiated.
  self.switchCell;
  return switchWidget;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Settings";
  
  // Load things
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  self.isSyncEnabled = [defaults boolForKey:SYNC_ENABLED_KEY];
  
  self.username = [defaults stringForKey:USERNAME_KEY];
  self.password = [defaults stringForKey:PASSWORD_KEY];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self.tableView reloadData];
}

- (BOOL) isSyncEnabled
{
  return self.switchWidget.on;
}
- (void) setIsSyncEnabled:(BOOL)on
{
  [self.switchWidget setOn:on animated:NO];
}

- (void) onClickSwitch:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL wasOn = [defaults boolForKey:SYNC_ENABLED_KEY];
  BOOL on = self.switchWidget.on;
  
  if (on == wasOn)
  {
    return;
  }
      
  [defaults setBool:on forKey:SYNC_ENABLED_KEY];
  
  NSIndexSet *set = [NSIndexSet indexSetWithIndex:1];
  if (on)
  {
    [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationFade];
  }
  else
  {
    [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationFade];
  }
}

- (BOOL) hasPassword
{
  return self.password && [self.password length] > 0;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1 + self.isSyncEnabled;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case 0:
      return 1;
    case 1:
      return 2;
    default:
      return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell;
  
  if ([indexPath section] == 0)
  {
    cell = self.switchCell;
    cell.textLabel.text = @"Sync enabled";
  }
  else
  {
    NSString *cellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                     reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([indexPath row] == 0)
    {
      cell.textLabel.text = @"Google Username";
      cell.detailTextLabel.text = self.username ? self.username : @"";
    }
    else
    {
      cell.textLabel.text = @"Google Password";
      cell.detailTextLabel.text = [self hasPassword] ? @"••••••••" : @"";
    }
  }
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([indexPath section] != 1)
  {
    return nil;
  }
  
  TextFieldViewController *tfvc = [[TextFieldViewController alloc] initWithNibName:@"TextFieldView" bundle:nil];
  
  tfvc.target = self;
  
  if ([indexPath row] == 0)
  {
    tfvc.title = @"Google Username";
    tfvc.placeholder = @"some@user.com";
    tfvc.text = self.username;
    tfvc.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    tfvc.saveAction = @selector(saveUsername:);
  }
  else
  {
    tfvc.title = @"Google Password";
    tfvc.textField.secureTextEntry = YES;
    tfvc.saveAction = @selector(savePassword:);
  }
  
  [self.navigationController pushViewController:tfvc animated:YES];
  
  return nil;
}

- (void)saveUsername:(id)sender
{
  TextFieldViewController *tfvc = (TextFieldViewController*)sender;
  self.username = [tfvc.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:self.username forKey:USERNAME_KEY];
}
- (void)savePassword:(id)sender
{
  TextFieldViewController *tfvc = (TextFieldViewController*)sender;
  self.password = tfvc.text;
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:self.password forKey:PASSWORD_KEY];
}


- (void)dealloc
{
  [username release];
  [password release];
  [switchCell release];
  [switchWidget release];
  [super dealloc];
}


@end

