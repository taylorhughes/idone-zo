//
//  FilterViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 10/25/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSObject *selectedObject;

@end

@implementation FilterViewController

@synthesize contexts;
@synthesize projects;
@synthesize dueDates;
@synthesize sections;

@synthesize selectedObject;

@synthesize emptyFilterView;

- (id) initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self != nil)
  {
    self.projects = [NSArray array];
    self.contexts = [NSArray array];
    self.dueDates = [NSArray array];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.navigationItem.title = @"Filter Tasks";
  
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        target:self
                                                                        action:@selector(onClickDone:)];
  [self.navigationItem setRightBarButtonItem:done animated:animated];
  [done release];
  
  if ([self.projects count] + [self.contexts count] + [self.dueDates count] == 0)
  {
    self.tableView.tableHeaderView = self.emptyFilterView;
  }
  else
  {
    self.tableView.tableHeaderView = nil;
  }
  
  [self.tableView reloadData];
  
  NSIndexPath *selectedPath = nil;
  if (self.selectedObject)
  {
    for (NSUInteger i = 0; i < [self.sections count]; i++)
    {
      NSArray *section = (NSArray*)[self.sections objectAtIndex:i];
      for (NSUInteger j = 0; j < [section count]; j++)
      {
        if ([self.selectedObject isEqual:[section objectAtIndex:j]])
        {
          selectedPath = [NSIndexPath indexPathForRow:j inSection:i];
          break;
        }
      }
      if (selectedPath != nil)
      {
        break;
      }
    }
  }
  
  if (selectedPath != nil)
  {
    [self.tableView scrollToRowAtIndexPath:selectedPath 
                          atScrollPosition:UITableViewScrollPositionMiddle 
                                  animated:NO];
  }
  else
  {
    [self.tableView scrollRectToVisible:CGRectMake(0,0,10,10) animated:NO];
  }
}

- (NSArray*)sections
{
  if (!sections)
  {
    self.sections = [NSMutableArray arrayWithCapacity:3];
    if ([self.projects count] > 0)
    {
      [(NSMutableArray*)sections addObject:self.projects];
    }
    if ([self.contexts count] > 0)
    {
      [(NSMutableArray*)sections addObject:self.contexts];
    }
    if ([self.dueDates count] > 0)
    {
      [(NSMutableArray*)sections addObject:self.dueDates];
    }
  }
  return sections;
}

- (void)setContexts:(NSArray *)newContexts
{
  self.sections = nil;
  [contexts release];
  contexts = [newContexts retain];
}
- (void)setProjects:(NSArray *)newProjects
{
  self.sections = nil;
  [projects release];
  projects = [newProjects retain];
}
- (void)setDueDates:(NSArray *)newDueDates
{
  self.sections = nil;
  [dueDates release];
  dueDates = [newDueDates retain];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[self.sections objectAtIndex:section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSArray *array = [self.sections objectAtIndex:section];
  if (array == projects)
  {
    return @"Projects";
  }
  else if (array == contexts)
  {
    return @"Contexts";
  }
  else if (array == dueDates)
  {
    return @"Due Dates";
  }
  return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *section = [self.sections objectAtIndex:[indexPath section]];
  NSObject *object = [section objectAtIndex:[indexPath row]];
  if (section == self.projects)
  {
    cell.textLabel.text = ((Project*)object).name;
  }
  else if (section == self.contexts)
  {
    cell.textLabel.text = [@"@" stringByAppendingString:((Context*)object).name];
  }
  else if (section == self.dueDates)
  {
    cell.textLabel.text = [[Task dueDateFormatter] stringFromDate:(NSDate*)object];
  }
  
  cell.textLabel.textColor = [UIColor blackColor];
  cell.accessoryType = UITableViewCellAccessoryNone;
  if ([object isEqual:self.selectedObject])
  {
    cell.textLabel.textColor = DONEZO_SELECTED_TEXT_COLOR;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *section = [self.sections objectAtIndex:[indexPath section]];
  NSObject *object = [section objectAtIndex:[indexPath row]];
  
  if ([object isEqual:self.selectedObject])
  {
    self.selectedObject = nil;
  }
  else
  {
    self.selectedObject = object;
  }
  
  [self.tableView reloadData];
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  
  NSDictionary *info = [NSDictionary dictionary];
  if (self.selectedObject)
  {
    info = [NSDictionary dictionaryWithObject:self.selectedObject forKey:@"filteredObject"];
  }
  
  [dnc postNotificationName:DonezoShouldFilterListNotification 
                     object:self
                   userInfo:info];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickDone:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reset
{
  self.sections = nil;
  self.contexts = nil;
  self.projects = nil;
  self.dueDates = nil;
  self.selectedObject = nil;
  [self.tableView reloadData];
}


- (void)dealloc
{
  [contexts release];
  [projects release];
  [dueDates release];
  [sections release];
  [selectedObject release];
  [super dealloc];
}


@end

