
#import "MainViewController.h"

// Static date range creation

@interface MainViewController ()

- (void) loadListViewForList:(TaskList*)list;
- (void) loadListViewForList:(TaskList*)list animated:(BOOL)animated;
- (void) recordViewedList:(TaskList*)list;

@end

@implementation MainViewController

@synthesize taskLists;

- (void)viewDidLoad
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  TaskList *lastViewed = [SettingsHelper lastViewedListInContext:appDelegate.managedObjectContext];
  if (lastViewed != nil)
  {
    [self loadListViewForList:lastViewed animated:NO];
  }
  
  UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self action:@selector(onClickAddList:)];
  self.navigationItem.rightBarButtonItem = add;
  [add release];
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self
          selector:@selector(donezoDataUpdated:) 
              name:DonezoDataUpdatedNotification
            object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self recordViewedList:nil];
}

- (ListViewController *)listViewController
{
  if (listViewController == nil)
  {
    listViewController = [[ListViewController alloc] initWithNibName:@"ListView" bundle:nil];
  }
  return listViewController;
}

- (ArchivedListViewController *)archivedListViewController
{
  if (archivedListViewController == nil)
  {
    archivedListViewController = [[ArchivedListViewController alloc] initWithNibName:@"ArchivedListView" bundle:nil];
  }
  return archivedListViewController;
}

- (SettingsViewController *)settingsViewController
{
  if (settingsViewController == nil)
  {
    settingsViewController = [[SettingsViewController settingsViewController] retain];
  }
  return settingsViewController;
}

- (NSArray*)archivedLabels
{
  if (!archivedLabels)
  {
    archivedLabels = [[NSArray alloc] initWithObjects:
                      @"Today",
                      @"Yesterday",
                      @"This Week",
                      @"Last Week",
                      nil];
  }
  return archivedLabels;
}

- (NSArray*)getStartAndEndDatesForArchivedLabelPosition:(NSUInteger)index
{
  NSDate *start = [NSDate date];
  NSDate *end = [NSDate date];
  
  switch (index)
  {
    case 0:
      // Today: midnight this morning to midnight tonight, local time zone
      start = [DonezoDates thisMorningAtMidnight];
      end =   [DonezoDates tonightAtMidnight];
      break;
    case 1:
      // Yesterday: midnight this morning to midnight yesterday morning
      start = [DonezoDates yesterdayMorningAtMidnight];
      end =   [DonezoDates thisMorningAtMidnight];
      break;
    case 2:
      // This Week: midnight this past sunday to midnight next saturday
      start = [DonezoDates beginningOfThisWeek];
      end =   [DonezoDates endOfThisWeek];
      break;
    case 3:
      // Last Week: midnight two sundays ago to midnight this past sunday
      start = [DonezoDates beginningOfLastWeek];
      end =   [DonezoDates beginningOfThisWeek];
      break;
  }
  
  return [NSArray arrayWithObjects:start, end, nil];
}

- (void) recordViewedList:(TaskList*)list
{
  [SettingsHelper setLastViewedList:list];
}

- (void) loadListViewForList:(TaskList*)list animated:(BOOL)animated
{
  self.listViewController.taskList = list;
  [self recordViewedList:list];
  
  [self.navigationController pushViewController:self.listViewController animated:animated];
}
- (void) loadListViewForList:(TaskList*)list
{
  [self loadListViewForList:list animated:YES];
}


- (void) onClickAddList:(id)sender
{
  if ([self.taskLists count] >= DONEZO_MAX_NUM_LISTS)
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too many task lists!"
                                                    message:@"You've hit the maximum number of lists. "
                                                             "Try combining your tasks into fewer lists and filtering by project."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    return;
  }
  
  TextFieldViewController *tfvc = [TextFieldViewController textFieldViewController];
  
  tfvc.title = @"New Task List";
  tfvc.placeholder = @"New Task List";
  tfvc.saveAction = @selector(addList:);
  tfvc.target = self;
  
  UINavigationController *modalNavigationController =
    [[[UINavigationController alloc] initWithRootViewController:tfvc] autorelease];
  [self presentViewController:modalNavigationController animated:YES completion:nil];
}

- (void) addList:(id)sender
{
  TextFieldViewController *tfvc = (TextFieldViewController*)sender;
  NSString *name = [tfvc.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSLog(@"Adding new list with name %@", name);
  
  if ([name isEqualToString:@""])
  {
    // Empty string; should we display an alert or something?
    return;
  }
  
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = appDelegate.managedObjectContext;
  TaskList *newList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:context];
  newList.name = name;
  
  NSError *error = nil;
  if (![context save:&error])
  {
    NSLog(@"Error saving new task list with name %@ and error %@", name, [error localizedDescription]);
  }
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc postNotificationName:DonezoDataUpdatedNotification object:self];
  [dnc postNotificationName:DonezoShouldSyncNotification object:self];
}

- (void) donezoDataUpdated:(NSNotification*)notification
{
  NSLog(@"Handling donezoDataUpdated notification");
  self.taskLists = nil;
  [self.tableView reloadData];
}

- (NSArray *) taskLists
{
  if (taskLists == nil)
  {
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *listsRequest = [appDelegate.managedObjectModel fetchRequestFromTemplateWithName:@"taskLists"
                                                                              substitutionVariables:[NSDictionary dictionary]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sorters = [NSArray arrayWithObjects:sort, nil];
    listsRequest.sortDescriptors = sorters;
    [sort release];
    
    NSError *error = nil;
    
    self.taskLists = [appDelegate.managedObjectContext executeFetchRequest:listsRequest error:&error];
    if (self.taskLists == nil)
    {
      // handle error
      NSLog(@"No task lists, something is majorly wrong.");
    }
  }
  return taskLists;
}



#pragma mark Table Delegate and Data Source Methods


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [indexPath section] == 0 && [self.taskLists count] > 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    // Temporarily suspend updates so the list doesn't explode when, during sync, 
    // a DonezoDataUpdatedNotification comes in and wipes out the list on context save
    [dnc removeObserver:self
                   name:DonezoDataUpdatedNotification
                 object:nil];
    
    TaskList *list = [self.taskLists objectAtIndex:[indexPath row]];
    
    list.isDeleted = YES;
    
    if (!list.key)
    {
      [list.managedObjectContext deleteObject:list];
    }
    
    NSError *error = nil;
    [list.managedObjectContext save:&error];
    if (error != nil)
    {
      NSLog(@"Error deleting list object! %@ %@", [error description], [error userInfo]);
    }
    
    self.taskLists = nil;
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [dnc addObserver:self
            selector:@selector(donezoDataUpdated:) 
                name:DonezoDataUpdatedNotification
              object:nil];
    
    [dnc postNotificationName:DonezoDataUpdatedNotification object:self];
    [dnc postNotificationName:DonezoShouldSyncNotification object:self];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 3;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    // regular lists
    case 0:
      return [self.taskLists count];
    
    // archived tasks
    case 1:
      return [self.archivedLabels count];
      
    // settings
    case 2:
      return 1;
      
    default:
      return 0;
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    // archived tasks
    case 1:
      return @"Archived Tasks";
      
    default:
      return nil;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
  if (cell == nil)
  {
    // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyIdentifier"] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  TaskList *taskList = nil;
  switch ([indexPath section])
  {
    case 0:
      taskList = [self.taskLists objectAtIndex:indexPath.row];
      cell.textLabel.text = taskList.name;
      
      // Commented out because we need to reloadData when the count changes (new task, task deleted)
      NSUInteger count = [taskList displayTasksCount];
      if (count == 0)
      {
        cell.detailTextLabel.text = @"No tasks";
      }
      else if (count == 1)
      {
        cell.detailTextLabel.text = @"1 task";
      }
      else if (count > 1)
      {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d tasks", count];
      }
      break;
      
    // archived tasks
    case 1:
      cell.textLabel.text = [self.archivedLabels objectAtIndex:[indexPath row]];
      // Setting this to an empty string is required to fix a rendering issue in iPhoneOS 3.1.2
      cell.detailTextLabel.text = @"";
      break;
      
    case 2:
      cell.textLabel.text = @"Settings";
      // Setting this to an empty string is required to fix a rendering issue in iPhoneOS 3.1.2
      cell.detailTextLabel.text = @"";
  }
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch ([indexPath section])
  {
    case 0:
      [self loadListViewForList:[self.taskLists objectAtIndex:indexPath.row]];    
      break;
      
    case 1:
      self.archivedListViewController.title = [self.archivedLabels objectAtIndex:[indexPath row]];
      NSArray *range = [self getStartAndEndDatesForArchivedLabelPosition:[indexPath row]];

      self.archivedListViewController.start = [range objectAtIndex:0];
      self.archivedListViewController.end   = [range objectAtIndex:1];
      [self.navigationController pushViewController:self.archivedListViewController animated:YES];
      break;
      
    case 2:
      [self.navigationController pushViewController:self.settingsViewController animated:YES];
      break;
  }

  return nil;
}


- (void) dealloc
{
  [taskLists release];
  [listViewController release];
  [settingsViewController release];
  [archivedListViewController release];
  [archivedLabels release];
  
  [super dealloc];
}

@end
