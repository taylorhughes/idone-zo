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
- (void) createTextView;
@end

@implementation EditProjectPicker

@synthesize options, target, saveAction;

- (id)init
{
  self = [super init];
  [self createTextView];
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

- (void)createTextView
{
  CGRect frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
  
	textView = [[[UITextView alloc] initWithFrame:frame] retain];
  textView.textColor = [UIColor blackColor];
  textView.font = [UIFont systemFontOfSize:18.0];
  textView.backgroundColor = [UIColor whiteColor];
	
	textView.returnKeyType = UIReturnKeyDefault;
  textView.keyboardType = UIKeyboardTypeDefault;
}

- (NSString*)selected
{
  return textView.text;
}
- (void)setSelected:(NSString *)newSelected
{
  textView.text = newSelected;
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

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
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
	return 50.0;
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
      ((TextViewCell*)cell).view = textView;
      break;
      
    case 1:
      cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NormalCell"] autorelease];
      }
      cell.text = ((Project*)[self.options objectAtIndex:[indexPath row]]).name;
      if ([cell.text isEqualTo:self.selected])
      {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
      self.selected = nil;
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
      self.selected = cell.text;
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [self.tableView reloadData];
    cell.selected = NO;
  }
  return nil;
}

- (void)dealloc
{
  [options release];
  [textView release];
  [super dealloc];
}


@end

