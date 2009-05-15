//
//  EditProjectPicker.m
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditProjectPicker.h"

@interface EditProjectPicker()
- (void) save:(id)sender;
- (void) cancel:(id)sender;
- (void) createtextField;
@end

#define FONT_SIZE 18.0

@implementation EditProjectPicker

@synthesize options, target, saveAction;

- (id)init
{
  self = [super init];
  [self createtextField];
  return self;
}

- (void)viewDidLoad
{
  UIBarButtonItem *save   = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self
                                                                           action:@selector(save:)] autorelease];
  
  UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(cancel:)] autorelease];
  
  self.navigationItem.rightBarButtonItem = save;
  self.navigationItem.leftBarButtonItem = cancel;
  
  self.tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped] autorelease];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.autoresizesSubviews = YES;
}

- (void)viewWillAppear:(BOOL)animated
{ 
  [super viewWillAppear:animated];
  
  if (options && ![self.tableView indexPathForSelectedRow])
  {
    for (NSInteger i = 0; i < self.options.count; i++)
    {
      NSString *option = (NSString*)[self.options objectAtIndex:i];
      if ([option isEqualToString:self.selected])
      {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        cell.selected = YES;
        break;
      }
    }
  }

  // this needs to come after setting selected to YES
  [self.tableView reloadData];
}

- (void)createtextField
{
  CGRect frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
  
	textField = [[[UITextField alloc] initWithFrame:frame] retain];
  textField.textColor = [UIColor blackColor];
  textField.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
  textField.backgroundColor = [UIColor whiteColor];
	textField.delegate = self;
	textField.returnKeyType = UIReturnKeyDone;
  textField.keyboardType = UIKeyboardTypeDefault;
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}

- (NSString*)selected
{
  return textField.text;
}
- (void)setSelected:(NSString *)newSelected
{
  textField.text = newSelected;
}

- (void)save:(id)sender
{  
  if (target && saveAction)
  {
    [target performSelector:saveAction withObject:self];
  }
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Text view methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];
  if (path)
  {
    [self.tableView deselectRowAtIndexPath:path animated:NO];
    [self.tableView reloadData];
  }
  return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch(section)
  {
    case 0:
      return 1;
    case 1:
      return [self.options count];
  }
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;
  
  switch ([indexPath section])
  {
    case 0:
      cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
      if (cell == nil) {
        cell = [[[TextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TableViewCell"] autorelease];
      }
      ((TextViewCell*)cell).view = textField;
      break;
      
    case 1:
      cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NormalCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.font = [UIFont systemFontOfSize:FONT_SIZE];
      }
      
      cell.text = [self.options objectAtIndex:[indexPath row]];
      if (cell.selected)
      {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
      }
      else
      {
        cell.accessoryType = UITableViewCellAccessoryNone;
      }
      break;
  }
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([indexPath section] == 1)
  {    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.selected = cell.text;

    [self save:self];
    return indexPath;
  }
  
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  [self.tableView reloadData];
}

- (void)dealloc
{
  [options release];
  [textField release];
  [super dealloc];
}


@end

