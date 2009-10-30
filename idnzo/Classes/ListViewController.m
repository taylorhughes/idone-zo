
#import "ListViewController.h"

@interface ListViewController ()

- (void) notifySync;
- (void) resetTasks;

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
@synthesize syncButton;


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UIBarButtonItem *add = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                        target:self action:@selector(addNewTask:)] autorelease];
  self.navigationItem.rightBarButtonItem = add;
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self
          selector:@selector(donezoDataUpdated:) 
              name:DonezoDataUpdatedNotification
            object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self resetTasks];
  [tableView reloadData];
}





- (void) donezoDataUpdated:(NSNotification*)notification
{
  // Is this necessary?
  [self resetTasks];
  [self.tableView reloadData];
}

- (TaskViewController *)taskViewController
{
  // Instantiate the detail view controller if necessary.
  if (taskViewController == nil)
  {
    self.taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil];
  }
  return taskViewController;
}

- (SortViewController *)sortViewController
{
  if (sortViewController == nil)
  {
    self.sortViewController = [[SortViewController alloc] initWithStyle:UITableViewStyleGrouped];
  }
  return sortViewController;
}

- (FilterViewController *)filterViewController
{
  if (filterViewController == nil)
  {
    self.filterViewController = [[FilterViewController alloc] initWithStyle:UITableViewStyleGrouped];
  }
  return filterViewController;
}

- (void) setTaskList:(TaskList *)list
{
  [taskList release];
  taskList = [list retain];
  self.title = taskList.name;
  
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
    NSString *sortKey = self.sortViewController.sortKey;
    NSSortDescriptor *sort = nil;
    if (sortKey && ([sortKey isEqual:@"body"] || [sortKey isEqual:@"project.name"]))
    {
      sort = [[[NSSortDescriptor alloc] initWithKey:sortKey
                                          ascending:!self.sortViewController.descending
                                           selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    }
    else
    {
      sort = [[[NSSortDescriptor alloc] initWithKey:sortKey
                                          ascending:!self.sortViewController.descending] autorelease];      
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
    NSObject *filter = self.filterViewController.selectedObject;
    
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSMutableArray *strings = [NSMutableArray arrayWithCapacity:2];
  
  if (![self.sortViewController isDefaultSort])
  {
    NSString *sortString = [NSString stringWithFormat:@"%@ %@", 
                            (self.sortViewController.descending ? @"\u25BC" : @"\u25B2"),
                            [self.sortViewController sortedTitle]];
    [strings addObject:sortString];
  }
  
  NSObject *filter = self.filterViewController.selectedObject;
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
    //                                          \u2219 bullet
    //                                          \u2236 "ratio" (:)
    //                                          \u205D tricolon
    //                                          \u2223 tall thin bar
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
  cell.task = task;
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ 
  TaskCell *cell = (TaskCell*)[self.tableView cellForRowAtIndexPath:indexPath];
  Task *clickedTask = [self.filteredTasks objectAtIndex:indexPath.row];
  
  if (cell.taskCellView.wasCompleted)
  {
    cell.taskCellView.wasCompleted = NO;
    clickedTask.isComplete = !clickedTask.isComplete;
    [clickedTask hasBeenUpdated];
    
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error = nil;
    if (![appDelegate.managedObjectContext save:&error])
    {
      NSLog(@"Error saving clicked task: %@ %@", [error description], [error userInfo]);
    }
    
    [self notifySync];
    [self.tableView reloadData];
  }
  else
  {
    TaskViewController *controller = self.taskViewController;
    [controller loadTask:clickedTask editing:NO positionInList:[indexPath row] ofTotalCount:[self.filteredTasks count]];
    
    [self.navigationController pushViewController:controller animated:YES];    
  }
  
  return nil;
}

- (IBAction)archiveTasks:(id)sender
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
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error = nil;
    if (![appDelegate.managedObjectContext save:&error])
    {
      NSLog(@"Error saving archived tasks: %@ %@", [error description], [error userInfo]);
    }
    [self resetTasks];
    
    [self.tableView deleteRowsAtIndexPaths:archivedPaths withRowAnimation:UITableViewRowAnimationFade];
    [self notifySync];
  }
}


- (void) notifySync
{
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];

  NSDictionary *info = [NSDictionary dictionaryWithObject:self.taskList forKey:@"list"];
  [dnc postNotificationName:DonezoShouldSyncNotification object:self userInfo:info];
}

- (void)addNewTask:(id)sender
{
  TaskViewController *tvc = [[[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil] autorelease];
  [tvc loadEditingWithNewTaskForList:self.taskList];
  
  UINavigationController *modalNavigationController =
    [[[UINavigationController alloc] initWithRootViewController:tvc] autorelease];
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];
}

- (IBAction) sort:(id)sender
{
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
  [super dealloc];
}

@end
