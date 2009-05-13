//
//  EditProjectPicker.m
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditProjectPicker.h"

@interface EditProjectPicker()
@end

@implementation EditProjectPicker

@synthesize options, selected;

- (void)viewDidLoad
{
  self.tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped] autorelease];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.autoresizesSubviews = YES;
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
      ((TextViewCell*)cell).view.text = self.selected;
      break;
      
    case 1:
      cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NormalCell"] autorelease];
      }
      cell.text = ((Project*)[self.options objectAtIndex:[indexPath row]]).name;
      break;
  }
  
  return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([indexPath section] == 1)
  {
    return UITableViewCellEditingStyleDelete;
  }
  return UITableViewCellEditingStyleNone;
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
  [selected release];
  [super dealloc];
}


@end

