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

+ (SettingsViewController*) settingsViewControllerWithSyncEnabled
{
  [SettingsHelper setIsSyncEnabled:YES];
  return [self settingsViewController];
}
+ (SettingsViewController*) settingsViewController
{
  return [[[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil] autorelease];
}

- (UITableViewCell*)switchCell
{
  if (!switchCell)
  {
    self.switchCell = [[UITableViewCell alloc] init];
    [self.switchCell release];
    
    self.switchWidget = [[UISwitch alloc] init];
    [self.switchWidget release];
    
    CGFloat x = self.switchCell.frame.size.width - 112;
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
  
  self.longOperationDialogView.frame = self.navigationController.view.frame;
  [self.longOperationDialogView setAlpha:0.0];
  [self.navigationController.view addSubview:self.longOperationDialogView];
  
  self.isSyncEnabled = [SettingsHelper isSyncEnabled];
  self.username = [SettingsHelper username];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if ([self.navigationController.viewControllers count] == 1)
  {
    // In a modal view; add a button
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self 
                                                                          action:@selector(dismiss:)];
    self.navigationItem.rightBarButtonItem = done;
    [done release];
  }
  
  [self.tableView reloadData];
}

- (void) viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  
  if ([self.navigationController.viewControllers count] > 1)
  {
    // If we go deeper (ie. to edit the username/pass), do not do this. Only do this if we go further up.
    return;
  }
  
  if ([SettingsHelper isSyncEnabled] && ![SettingsHelper hasUsername])
  {
    // If they don't set a username, just set sync to be disabled.
    [SettingsHelper setIsSyncEnabled:NO];
    self.isSyncEnabled = NO;
  }
}

- (void) dismiss:(id)sender
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

//
// PROPERTY ACCESSOR / MUTATOR
//
- (BOOL) isSyncEnabled
{
  return self.switchWidget.on;
}
- (void) setIsSyncEnabled:(BOOL)enabled
{
  self.switchWidget.on = enabled;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"Sync to done-zo.com";
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
  
  TextFieldViewController *tfvc = [TextFieldViewController textFieldViewController];
  
  tfvc.target = self;
  
  if ([indexPath row] == 0)
  {
    tfvc.title = @"Google Username";
    tfvc.placeholder = @"john.smith@gmail.com";
    tfvc.text = self.username;
    tfvc.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    tfvc.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tfvc.textField.keyboardType = UIKeyboardTypeEmailAddress;
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

- (void)reallySaveUsername
{
  if ([SettingsHelper hasUsername])
  {
    // It is possible that there is no username set currently, if they first set it to a blank box.
    [[NSNotificationCenter defaultCenter] postNotificationName:DonezoShouldSyncNotification object:self];
  }
  
  [self.longOperationLabel setText:@"Syncing existing account..."];
  
  [UIView beginAnimations:@"Show View" context:nil];
  [self.longOperationDialogView setAlpha:1.0];
  [UIView commitAnimations];
  
  [self performSelectorInBackground:@selector(reallySaveUsernameOperation:) withObject:self];
}

- (void)reallySaveUsernameOperation:(id)sender
{
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  [appDelegate waitForSyncToFinishAndReinitializeDatastore];
  
  [SettingsHelper setUsername:self.username];
  [SettingsHelper resetPassword];
  
  [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DonezoShouldResetNotification object:self];
    
  [UIView beginAnimations:@"Hide View" context:nil];
  [self.longOperationDialogView setAlpha:0.0];
  [UIView commitAnimations];
  
  [pool release];
}

- (void)dontSaveUsername
{
  self.username = [SettingsHelper username];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  switch(buttonIndex)
  {
    // save:
    case 1:
      [self reallySaveUsername];
      break;
      
    // cancel
    case 0:
    default:
      [self dontSaveUsername];
      [self.tableView reloadData];
      break;
  }
}

- (void)saveUsername:(id)sender
{
  TextFieldViewController *tfvc = (TextFieldViewController*)sender;
  self.username = [tfvc.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if ([self.username length] == 0)
  {
    // Do not change the sync'd username; that is, the app has had a chance to sync
    // to a different account already, so don't erase the fact that it has synced.
    [SettingsHelper setUsername:self.username];
  }
  else if ([SettingsHelper hasSyncedUsername] && 
           ![[self.username lowercaseString] isEqualToString:[[SettingsHelper syncedUsername] lowercaseString]])
  {
    UIAlertView *alertTest = [[UIAlertView alloc]
                              initWithTitle:@"Really change user?"
                                    message:@"Changing your synced account will remove the tasks stored "
                                             "on your phone. After setting the new account's password, "
                                             "the new tasks will be downloaded."
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Change User",nil ];
    
    [alertTest show];
    [alertTest autorelease];
  }
  else
  {
    [SettingsHelper setUsername:self.username];
  }
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
  [longOperationDialogView release];
  [longOperationLabel release];
  [super dealloc];
}


@end

