//
//  SettingsViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 12/6/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

- (void) notifyResetAndSync;

@end

@implementation SettingsViewController

@synthesize switchCell, switchWidget;
@synthesize username;

@synthesize longOperationDialogView;
@synthesize longOperationLabel;

@synthesize confirm;

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
  
  self.isSyncEnabled = [SettingsHelper isSyncEnabled];
  self.username = [SettingsHelper username];
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
  BOOL on = self.switchWidget.on;
  
  if (on == [SettingsHelper isSyncEnabled])
  {
    return;
  }
      
  [SettingsHelper setIsSyncEnabled:on];
  
  NSIndexSet *set = [NSIndexSet indexSetWithIndex:1];
  if (on)
  {
    [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationFade];
  }
  else
  {
    [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationFade];
  }
  
  if ([SettingsHelper hasUsername])
  {
    [self notifyResetAndSync];
  }
}

- (void) notifyResetAndSync
{
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc postNotificationName:DonezoShouldResetAndSyncNotification object:self userInfo:nil];  
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
      cell.detailTextLabel.text = [SettingsHelper hasPassword] ? @"••••••••" : @"";
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

- (void)reallySaveUsername:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:DonezoShouldSyncNotification object:self];
  
  [self.longOperationLabel setText:@"Syncing existing account..."];
  self.longOperationDialogView.frame = self.navigationController.view.frame;
  [self.navigationController.view addSubview:self.longOperationDialogView];
  
  [self performSelectorInBackground:@selector(reallySaveUsernameOperation:) withObject:self];
}
- (void)reallySaveUsernameOperation:(id)sender
{
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  [appDelegate waitForSyncToFinishAndReinitializeDatastore];
  
  [SettingsHelper setUsername:self.username];
  
  [self.longOperationLabel setText:@"Syncing new account..."];
  [[NSNotificationCenter defaultCenter] postNotificationName:DonezoShouldResetAndSyncNotification object:self];
  
  [self.longOperationDialogView removeFromSuperview];
  
  [pool release];
}

- (void)dontSaveUsername:(id)sender
{
  self.username = [SettingsHelper username];
}
- (void)saveUsername:(id)sender
{
  TextFieldViewController *tfvc = (TextFieldViewController*)sender;
  self.username = [tfvc.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if ([SettingsHelper hasUsername] &&
      ![[self.username lowercaseString] isEqualToString:[[SettingsHelper username] lowercaseString]])
  {
    // Changed usernames!
    self.confirm = [ConfirmationViewController confirmationViewWithSuperview:self.navigationController.view];
    self.confirm.target = self;
    
    [self.confirm.confirmButton setTitle:@"Change Username" forState:UIControlStateNormal];
    self.confirm.confirmAction = @selector(reallySaveUsername:);
    
    [self.confirm.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.confirm.cancelAction = @selector(dontSaveUsername:);
    
    self.confirm.afterHideAction = @selector(cleanupConfirmation:);
    [self.confirm show];
  }
  else
  {
    [SettingsHelper setUsername:self.username];
  }
}
- (void) cleanupConfirmation:(id)sender
{
  self.confirm = nil;
}

- (void)savePassword:(id)sender
{
  TextFieldViewController *tfvc = (TextFieldViewController*)sender;
  [SettingsHelper setPassword:tfvc.text];
  
  [self notifyResetAndSync];
}


- (void)dealloc
{
  [username release];
  [switchCell release];
  [switchWidget release];
  [confirm release];
  [longOperationDialogView release];
  [longOperationLabel release];
  [super dealloc];
}


@end

