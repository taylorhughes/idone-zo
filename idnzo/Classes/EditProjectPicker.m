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
@end

#define FONT_SIZE 18.0
#define TEXT_FIELD_VPADDING 11.0
#define TEXT_FIELD_HPADDING 10.0

@implementation EditProjectPicker

@synthesize options, target, saveAction;
@synthesize appendSelections;

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    appendSelections = NO;
    
    textField = [[[UITextField alloc] initWithFrame:CGRectZero] retain];
    textField.delegate = self;
    textField.placeholder = @"New project";
    
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    
    textField.returnKeyType = UIReturnKeyDone;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    
    textField.contentMode = UIViewContentModeLeft;
  }
  return self;
}

- (void)viewDidLoad
{
  UIBarButtonItem *save   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                           target:self
                                                                           action:@selector(save:)];
  
  UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(cancel:)];
  
  self.navigationItem.rightBarButtonItem = save;
  self.navigationItem.leftBarButtonItem = cancel;
  
  [save release];
  [cancel release];
  
  self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.autoresizesSubviews = YES;
  [self.tableView release];
}

- (BOOL) selectedContains:(NSString*)option
{
  if (self.appendSelections)
  {
    option = [option stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[cd] %@",
                              [NSString stringWithFormat:@".*\\b%@\\b.*", option]];
    return [predicate evaluateWithObject:self.selected];
  }
  else
  {
    return [self.selected isEqualToString:option];
  }
}

- (void)viewWillAppear:(BOOL)animated
{ 
  [super viewWillAppear:animated];
  
  if (options)
  {
    for (NSInteger i = 0; i < self.options.count; i++)
    {
      NSString *option = (NSString*)[self.options objectAtIndex:i];
      
      if ([self selectedContains:option])
      {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
        // just scroll to the first one
        break;
      }
    }
  }

  // this needs to come after setting selected to YES
  [self.tableView reloadData];
}

- (NSString*)selected
{
  return textField.text;
}
- (void)setSelected:(NSString *)newSelected
{
  NSLog(@"Setting text to %@", newSelected);
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

#pragma mark Text view methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  [self.tableView reloadData];
  return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;
  
  switch ([indexPath section])
  {
    case 0:
      cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
      if (cell == nil)
      {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TextViewCell"] autorelease];
        [cell.contentView addSubview:textField];
        
        CGRect frame = cell.contentView.frame;
        textField.frame = CGRectMake(frame.origin.x + TEXT_FIELD_HPADDING, 
                                     frame.origin.y + TEXT_FIELD_VPADDING,
                                     frame.size.width - TEXT_FIELD_HPADDING * 4,
                                     frame.size.height - TEXT_FIELD_VPADDING * 2);
      }
      break;
      
    case 1:
      cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
      if (cell == nil)
      {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NormalCell"] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
      }
      
      cell.textLabel.text = [self.options objectAtIndex:[indexPath row]];
      if ([self selectedContains:cell.textLabel.text])
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
    if (self.appendSelections)
    {
      if (![self selectedContains:cell.textLabel.text])
      {
        if (self.selected != nil && ![self.selected isEqual:@""])
        {
          self.selected = [self.selected stringByAppendingFormat:@" %@", cell.textLabel.text];
        }
        else
        {
          self.selected = cell.textLabel.text;
        }
      }
    }
    else
    {
      self.selected = cell.textLabel.text;
    }
    
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

