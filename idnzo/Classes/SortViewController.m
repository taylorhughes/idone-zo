//
//  SortViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 10/22/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "SortViewController.h"

@interface SortViewController ()

+ (NSString*) titleForIndex:(NSUInteger)index;

@end

@implementation SortViewController


NSArray *sortKeys;

+ (void) initialize
{
  sortKeys = [NSArray arrayWithObjects:
              @"sortDate",
              @"body",
              @"project.name",
              @"dueDate",
              @"complete",
              nil];
  [sortKeys retain];
}

+ (NSString*) sortKeyForIndex:(NSInteger)index
{
  return [sortKeys objectAtIndex:index];
}

+ (NSString*)sortedTitleForKey:(NSString*)sortKey;
{
  return [self titleForIndex:[sortKeys indexOfObject:sortKey]];
}

+ (NSString*) titleForIndex:(NSUInteger)index
{
  switch (index)
  {
    case 1:
      return @"Task";
    case 2:
      return @"Project";
    case 3:
      return @"Due Date";
    case 4:
      return @"Completed";
  }
  return @"Default";
}

+ (NSString*)defaultSortKey
{
  return [sortKeys objectAtIndex:0];
}
+ (BOOL) isDefaultSort:(NSString*)sortKey
{
  return [sortKeys indexOfObject:sortKey] == 0;
}


@synthesize descending;

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
  
  [self.tableView reloadData];
}

- (void) setSortKey:(NSString*)sortKey
{
  // Load the view so we know the "view loaded" event has fired.
  self.view;
  selectedIndex = [sortKeys indexOfObject:sortKey];
}
- (NSString*) sortKey
{
  return [sortKeys objectAtIndex:selectedIndex];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }
  
  cell.textLabel.text = [[self class] titleForIndex:[indexPath row]];
  
  cell.textLabel.textColor = [UIColor blackColor];
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.detailTextLabel.text = nil;
  if (selectedIndex == [indexPath row])
  {
    cell.textLabel.textColor = DONEZO_SELECTED_TEXT_COLOR;
    if (selectedIndex == 0)
    {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if (descending)
    {
      cell.detailTextLabel.text = @"Descending \u25BC";
    }
    else
    {
      cell.detailTextLabel.text = @"Ascending \u25B2";
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
  
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  
  NSMutableDictionary *info = [NSMutableDictionary dictionary];
  [info setObject:self.sortKey forKey:@"sortKey"];
  [info setObject:[NSNumber numberWithInt:self.descending] forKey:@"descending"];
  
  [dnc postNotificationName:DonezoShouldSortListNotification 
                     object:self
                   userInfo:info];
  
  
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

