//
//  SortViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 10/22/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "SortViewController.h"

@interface SortViewController ()

- (NSString*) titleForIndex:(NSUInteger)index;

@end

@implementation SortViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  selectedIndex = 0;
  descending    = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.navigationItem.title = @"Sort Tasks";
  
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        target:self
                                                                        action:@selector(onClickDone:)];
  [self.navigationItem setRightBarButtonItem:done animated:animated];
  [done release];
}

- (BOOL)isDefaultSort
{
  return selectedIndex == 0;
}

- (NSSortDescriptor*) sorter
{
  // return the proper sorter given the current selection
  NSString *key = nil;
  switch (selectedIndex)
  {
    case 1:
      key = @"body";
      break;
    case 2:
      key = @"project.name";
      break;
    case 3:
      key = @"dueDate";
      break;
      
    default:
    case 0:
      key = @"sortDate";
      break;
  }
  
  return [[[NSSortDescriptor alloc] initWithKey:key ascending:!descending] autorelease];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 4;
}

- (NSString*) sortedTitle
{
  NSString *str = [self titleForIndex:selectedIndex];
  if (!descending)
  {
    return str;
  }
  return [str stringByAppendingString:@", Descending"];
}

- (NSString*) titleForIndex:(NSUInteger)index
{
  switch (index)
  {
    case 1:
      return @"Task Body";
    case 2:
      return @"Project";
    case 3:
      return @"Due Date";
  }
  return @"Default";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }
  
  cell.textLabel.text = [self titleForIndex:[indexPath row]];
  
  cell.textLabel.textColor = [UIColor blackColor];
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.detailTextLabel.text = nil;
  if (selectedIndex == [indexPath row])
  {
    cell.textLabel.textColor = [UIColor colorWithRed:(50.0/255.0) green:(79.0/255.0) blue:(133.0/255.0) alpha:1.0];
    if (selectedIndex == 0)
    {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if (descending)
    {
      cell.detailTextLabel.text = @"Descending";
    }
    else
    {
      cell.detailTextLabel.text = @"Ascending";
    }
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (selectedIndex == [indexPath row] && selectedIndex > 0)
  {
    descending = !descending;
  }
  else
  {
    descending = NO;
  }

  selectedIndex = [indexPath row];
  
  [self.tableView reloadData];
  [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)onClickDone:(id)sender
{
  [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}


- (void)dealloc
{
  [super dealloc];
}

@end

