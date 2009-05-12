//
//  EditProjectPicker.m
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditProjectPicker.h"

@implementation EditProjectPicker

@synthesize options, selected;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad
{
  self.tableView = [[[UITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStyleGrouped] autorelease];
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


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
  }
  
  switch ([indexPath section])
  {
    case 0:
      cell.text = self.selected;
      break;
      
    case 1:
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
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
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

