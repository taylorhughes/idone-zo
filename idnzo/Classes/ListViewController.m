
#import "ListViewController.h"

@interface ListViewController ()

- (void) notifySync;
- (void) notifySync:(BOOL)userForced;
- (void) resetTasks;
- (void) filterList:(id)sender;
- (void) archiveTasks;

@property (retain, nonatomic) NSArray *tasks;
@property (retain, nonatomic) NSArray *filteredTasks;
@property (retain, nonatomic) SortViewController *sortViewController;
@property (retain, nonatomic) FilterViewController *filterViewController;

@end

@implementation ListViewController

@synthesize tableView;
@synthesize taskList;

@synthesize tasks;
@synthesize filteredTasks;

@synthesize taskViewController;
@synthesize sortViewController;
@synthesize filterViewController;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  suspendUpdates = NO;
  
  UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self
                                                                       action:@selector(onClickAddTask:)];
  self.navigationItem.rightBarButtonItem = add;
  [add release];
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  
  [dnc addObserver:self
          selector:@selector(donezoDataUpdated:) 
              name:DonezoDataUpdatedNotification
            object:nil];
  
  [dnc addObserver:self 
          selector:@selector(donezoSyncStatusChanged:)
              name:DonezoSyncStatusChangedNotification
            object:nil];
  
  [dnc addObserver:self
          selector:@selector(filterList:)
              name:DonezoShouldFilterListNotification
            object:nil];
  
  [dnc addObserver:self
          selector:@selector(sortList:)
              name:DonezoShouldSortListNotification
            object:nil];
  
  [dnc addObserver:self
          selector:@selector(toggleCompletedTask:)
              name:DonezoShouldToggleCompletedTaskNotification
            object:nil];
}


- (void) donezoDataUpdated:(NSNotification*)notification
{
  if (!suspendUpdates)
  {
    [self resetTasks];
    if ([self.view window])
    {
      [self.tableView reloadData];
    }
  }
}

// Number of pixels smaller the spinner should be than its default size.
#define SPINNER_SIZE_ADJUSTMENT 2
- (void) updateSyncStatusButton
{
  // If syncing is not enabled, remove the sync button from view.
  if (![SettingsHelper isSyncEnabled])
  {
    NSMutableArray *array = [toolbar.items mutableCopy];
    // Noop if syncButton is not in there
    [array removeObject:rightmostFlexibleSpace];
    [array removeObject:syncButton];
    if (syncingIndicator)
    {
      [array removeObject:syncingIndicator];
    }
    toolbar.items = array;
    [array release];
    
    return;
  }
  else
  {
    if (![toolbar.items containsObject:rightmostFlexibleSpace])
    {
      NSMutableArray *array = [toolbar.items mutableCopy];
      [array addObject:rightmostFlexibleSpace];
      toolbar.items = array;
      [array release];
    }
  }

  
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  if (!syncingIndicator)
  {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    // Make the frame slightly smaller to match the refresh button
    CGRect frame = spinner.frame;
    frame.size = CGSizeMake(frame.size.width - SPINNER_SIZE_ADJUSTMENT, frame.size.height - SPINNER_SIZE_ADJUSTMENT);
    spinner.frame = frame;
    [spinner startAnimating];
    
    syncingIndicator = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    [spinner release];
  }
  
  if ([appDelegate isSyncing:self.taskList])
  {
    NSMutableArray *array = [toolbar.items mutableCopy];
    // Noop if syncButton is not in there
    [array removeObject:syncButton];
    if (![toolbar.items containsObject:syncingIndicator])
    {
      [array addObject:syncingIndicator];
    }
    toolbar.items = array;
    [array release];
  }
  else
  {
    NSMutableArray *array = [toolbar.items mutableCopy];
    [array removeObject:syncingIndicator];
    if (![toolbar.items containsObject:syncButton])
    {
      [array addObject:syncButton];
    }
    toolbar.items = array;
    [array release];
  }
}

- (void) donezoSyncStatusChanged:(NSNotification*)notification
{
  // Only bother updating if we're showing
  if ([self.view window])
  {
    [self updateSyncStatusButton];
  }
}


- (void)viewWillAppear:(BOOL)animated
{
  [self resetTasks];
  [tableView reloadData];
  
  [self updateSyncStatusButton];
}


- (NSObject*)filteredObject
{
  return [SettingsHelper filteredObjectForList:self.taskList];
}
- (NSString*)sortKey
{
  NSString *key = [SettingsHelper sortKeyForList:self.taskList];
  if (key != nil)
  {
    return key;
  }
  return [SortViewController defaultSortKey];
}
- (BOOL)sortDescending
{
  return [SettingsHelper isSortDescendingForList:self.taskList];
}

- (void) filterList:(NSNotification*)notification
{
  NSObject *object = (NSObject*) [[notification userInfo] objectForKey:@"filteredObject"];
  
  [SettingsHelper setFilteredObject:object forList:self.taskList];
  
  // viewWillAppear automatically force-reloads these:
  //[self resetTasks];
  //[self.tableView reloadData];
}

- (void) sortList:(NSNotification*)notification
{
  NSString *sortKey = (NSString*) [[notification userInfo] objectForKey:@"sortKey"];
  NSNumber *descending = (NSNumber*) [[notification userInfo] objectForKey:@"descending"];
  
  [SettingsHelper setSortKey:sortKey forList:self.taskList];
  [SettingsHelper setSortDescending:[descending intValue] forList:self.taskList];
}



- (TaskViewController *)taskViewController
{
  // Instantiate the detail view controller if necessary.
  if (taskViewController == nil)
  {
    self.taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil];
    [self.taskViewController release];
  }
  return taskViewController;
}

- (SortViewController *)sortViewController
{
  if (sortViewController == nil)
  {
    self.sortViewController = [[SortViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.sortViewController release];
  }
  return sortViewController;
}

- (FilterViewController *)filterViewController
{
  if (filterViewController == nil)
  {
    self.filterViewController = [[FilterViewController alloc] initWithNibName:@"FilterView" bundle:nil];
    [self.filterViewController release];
  }
  return filterViewController;
}

- (void) setTaskList:(TaskList *)list
{
  [taskList release];
  taskList = [list retain];
  self.title = taskList.name;
  
  // Scroll to top
  [self.tableView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
  
  [self resetTasks];
}

- (void) resetTasks
{
  self.tasks = nil;
  self.filteredTasks = nil;
}

- (NSArray *)tasks
{
  if (!tasks)
  {
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [self.taskList tasksForListRequest];
    // Case-insensitive body sort
    NSString *sortKey = self.sortKey;
    NSSortDescriptor *sort = nil;
    if ([sortKey isEqual:@"body"] || [sortKey isEqual:@"project.name"])
    {
      sort = [[[NSSortDescriptor alloc] initWithKey:sortKey
                                          ascending:!self.sortDescending
                                           selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    }
    else
    {
      sort = [[[NSSortDescriptor alloc] initWithKey:sortKey
                                          ascending:!self.sortDescending] autorelease];      
    }

    NSSortDescriptor *secondarySort = [[NSSortDescriptor alloc] initWithKey:@"body" 
                                                                  ascending:YES 
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)];
    
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:sort, secondarySort, nil];
    [secondarySort release];
    
    NSError *error = nil;
    self.tasks = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil)
    {
      NSLog(@"Error fetching tasks! %@ %@", [error description], [error userInfo]);
      self.tasks = [NSArray array];
    }
    else
    {
      NSLog(@"Fetched %d tasks for list '%@'.", [self.tasks count], self.taskList.name);
    }
  }
  return tasks;
}

- (NSArray *)filteredTasks
{  
  if (!filteredTasks)
  {
    NSObject *filter = self.filteredObject;
    
    if (!filter)
    {
      self.filteredTasks = self.tasks;
    }
    else
    {
      NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[self.tasks count]];
      for (Task* task in self.tasks)
      {
        BOOL included = NO;
        if ([filter isKindOfClass:[NSDate class]])
        {
          included = [task.dueDate isEqual:filter];
        }
        else if ([filter isKindOfClass:[Project class]])
        {
          included = [task.project isEqual:filter];
        }
        else if ([filter isKindOfClass:[Context class]])
        {
          included = [task.contexts containsObject:filter];
        }
        
        if (included)
        {
          [filtered addObject:task];
        }
      }
      self.filteredTasks = filtered;
    }
  }
  return filteredTasks;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    Task *task = [self.filteredTasks objectAtIndex:[indexPath row]];
    
    NSLog(@"Deleting task: %@", task.body);
    
    task.isDeleted = YES;
    [task hasBeenUpdated];
    
    [self resetTasks];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // This will cause a donezodataupdated sync which will cause tasks to be reset and the table to be reloaded
    // So this should happen *after* deleteRowsAtIndexPaths is called
    [task.managedObjectContext save:nil];
    
    if (task.key)
    {
      [self notifySync];
    }
    else
    {
      [task.managedObjectContext deleteObject:task];
      [task.managedObjectContext save:nil];
    }
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc postNotificationName:DonezoDataUpdatedNotification object:self];
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSMutableArray *strings = [NSMutableArray arrayWithCapacity:2];
  
  if (![SortViewController isDefaultSort:self.sortKey])
  {
    NSString *sortString = [NSString stringWithFormat:@"%@ %@", 
                            (self.sortDescending ? @"\u25BC" : @"\u25B2"),
                            [SortViewController sortedTitleForKey:self.sortKey]];
    [strings addObject:sortString];
  }
  
  NSObject *filter = self.filteredObject;
  if (filter != nil)
  {
    NSString *filterString = @"";
    if ([filter isKindOfClass:[NSDate class]])
    {
      filterString = [[Task dueDateFormatter] stringFromDate:(NSDate*)filter];
    }
    else if ([filter isKindOfClass:[Project class]])
    {
      filterString = ((Project*)filter).name;
    }
    else if ([filter isKindOfClass:[Context class]])
    {
      filterString = [@"@" stringByAppendingString:((Context*)filter).name];
    }
    [strings addObject:filterString];    
  }
  
  if ([strings count] > 0)
  {
    //                                          \u25EE vertical ellipsis
    //                                          \u2236 "ratio" (:)
    //                                          \u205D tricolon
    //                                          \u2223 tall thin bar
    //                                          \u2219 bullet
    return [strings componentsJoinedByString:@" \u2219 "];
  }
  
  return nil;
}

// This table will always only have one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 1;
}

// One row per book, the number of books is the number of rows.
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
  return [self.filteredTasks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [TaskCellView height];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TaskCell *cell = (TaskCell*)[self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
  if (cell == nil)
  {
    // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
    cell = [[[TaskCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  Task *task = [self.filteredTasks objectAtIndex:indexPath.row];
  [cell displayLocalTask:task];
  
  return cell;
}

- (void)toggleCompletedTask:(NSNotification*)notification
{
  Task* clickedTask = [[notification userInfo] objectForKey:@"task"];
  
  clickedTask.isComplete = !clickedTask.isComplete;
  [clickedTask hasBeenUpdated];
  
  NSError *error = nil;
  if (![clickedTask.managedObjectContext save:&error])
  {
    NSLog(@"Error saving clicked task: %@ %@", [error description], [error userInfo]);
  }
  
  [self notifySync];
  [self.tableView reloadData];
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ 
  Task *clickedTask = [self.filteredTasks objectAtIndex:indexPath.row];
  
  TaskViewController *controller = self.taskViewController;
  [controller loadTask:clickedTask editing:NO positionInList:[indexPath row] ofTotalCount:[self.filteredTasks count]];
  
  [self.navigationController pushViewController:controller animated:YES];
  
  return nil;
}

- (IBAction)askToArchiveTasks:(id)sender
{
  BOOL hasCompleted = NO;
  for (Task* task in self.filteredTasks)
  {
    if (task.isComplete)
    {
      hasCompleted = YES;
      break;
    }
  }
  
  if (!hasCompleted)
  {
    NSString *message = @"Pressing this button will move completed tasks to the archive, but there are no completed tasks at the moment.";
    
    UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No tasks to archive"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  else
  {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    [sheet addButtonWithTitle:@"Archive Completed Tasks"];
    [sheet addButtonWithTitle:@"Cancel"];
    [sheet setDestructiveButtonIndex:0];
    [sheet setCancelButtonIndex:1];
    [sheet setDelegate:self];
    
    [sheet showInView:self.navigationController.view];
    
    [sheet release];
  }
}
- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0)
  {
    [self archiveTasks];
  }
}

- (void)archiveTasks
{
  NSMutableArray *archivedPaths = [NSMutableArray arrayWithCapacity:[self.filteredTasks count]];
  for (NSInteger i = 0; i < [self.filteredTasks count]; i++)
  {
    Task* task = [self.filteredTasks objectAtIndex:i];
    if (task.isComplete)
    {
      task.isArchived = YES;
      [task hasBeenUpdated];
      [archivedPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
  }
  if ([archivedPaths count] > 0)
  {
    //
    // This keeps the resultant donezoDataUpdated notification from
    // resetting the list under us, since we're manually removing rows 
    // from the table below.
    //
    suspendUpdates = YES;
    
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error = nil;
    if (![appDelegate.managedObjectContext save:&error])
    {
      NSLog(@"Error saving archived tasks: %@ %@", [error description], [error userInfo]);
    }
    
    [self resetTasks];
    // This may also cause donezoDataUpdated notifications
    [self notifySync];
    
    [self.tableView deleteRowsAtIndexPaths:archivedPaths withRowAnimation:UITableViewRowAnimationFade];
    
    suspendUpdates = NO;
  }
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc postNotificationName:DonezoDataUpdatedNotification object:self];
}

- (IBAction) sync:(id)sender
{
  [self notifySync:YES];
}

- (void) notifySync
{
  [self notifySync:NO];
}
- (void) notifySync:(BOOL)userForced
{
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];

  NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:self.taskList forKey:@"list"];
  if (userForced)
  {
    [info setValue:[NSNumber numberWithInt:1] forKey:@"userForced"];
  }
  [dnc postNotificationName:DonezoShouldSyncNotification object:self userInfo:info];
}

- (void) onClickAddTask:(id)sender
{
  TaskViewController *tvc = [[[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil] autorelease];
  [tvc loadEditingWithNewTaskForList:self.taskList withFilteredObject:self.filteredObject];
  
  UINavigationController *modalNavigationController =
    [[[UINavigationController alloc] initWithRootViewController:tvc] autorelease];
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];
}

- (IBAction) sort:(id)sender
{
  [self.sortViewController setSortKey:self.sortKey];
  [self.sortViewController setDescending:self.sortDescending];
  
  UINavigationController *modalNavigationController =
    [[[UINavigationController alloc] initWithRootViewController:self.sortViewController] autorelease];
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];  
}

- (IBAction) filter:(id)sender
{
  // These should maybe be cached or some such somehow. Only load them when self.tasks changes -- or something.
  NSMutableSet *projects = [NSMutableSet setWithCapacity:[self.tasks count]];
  NSMutableSet *contexts = [NSMutableSet setWithCapacity:[self.tasks count]];
  NSMutableSet *dueDates = [NSMutableSet setWithCapacity:[self.tasks count]];
  
  for (Task* task in self.tasks)
  {
    if (task.project)
    {
      [projects addObject:task.project]; 
    }
    if ([task.contexts count] > 0)
    {
      [contexts addObjectsFromArray:[task.contexts allObjects]];
    }
    if (task.dueDate)
    {
      [dueDates addObject:task.dueDate];
    }
  }
  
  [self.filterViewController setSelectedObject:self.filteredObject];
  self.filterViewController.contexts = [[contexts allObjects] sortedArrayUsingSelector:@selector(compare:)];
  self.filterViewController.projects = [[projects allObjects] sortedArrayUsingSelector:@selector(compare:)];
  self.filterViewController.dueDates = [[dueDates allObjects] sortedArrayUsingSelector:@selector(compare:)];
  
  UINavigationController *modalNavigationController =
    [[[UINavigationController alloc] initWithRootViewController:self.filterViewController] autorelease];
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];    
}


- (void)dealloc
{
  [tableView release];
  [taskList release];
  [tasks release];
  [filteredTasks release];
  
  [taskViewController release];
  [sortViewController release];
  [filterViewController release];
  
  [syncingIndicator release];
  
  [super dealloc];
}

@end
