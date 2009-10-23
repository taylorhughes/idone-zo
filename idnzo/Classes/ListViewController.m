
#import "ListViewController.h"

@interface ListViewController ()
- (void) notifySync;

@property (retain, nonatomic) NSArray *tasks;
@property (retain, nonatomic) SortViewController *sortViewController;

@end

@implementation ListViewController

@synthesize tableView;
@synthesize taskList;
@synthesize tasks;
@synthesize taskViewController;
@synthesize sortViewController;
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
  self.tasks = nil;
  [tableView reloadData];
}







- (void) donezoDataUpdated:(NSNotification*)notification
{
  // NSLog(@"ListViewController: Handled updated data.");
  self.tasks = nil;
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

- (void) setTaskList:(TaskList *)list
{
  if (taskList)
  {
    [taskList release];
  }
  if (tasks)
  {
    self.tasks = nil;
  }
  taskList = [list retain];
  self.title = [taskList name];
}

- (NSArray *)tasks
{
  if (!tasks)
  {
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [self.taskList tasksForListRequest];
    NSSortDescriptor *sort = self.sortViewController.sorter;
    NSSortDescriptor *secondarySort = [[NSSortDescriptor alloc] initWithKey:@"body" ascending:YES];
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
      NSLog(@"Fetched %d tasks for list '%@'.", [tasks count], self.taskList.name);
    }
  }
  return tasks;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (![self.sortViewController isDefaultSort])
  {
    return [NSString stringWithFormat:@"Sorted by %@", [self.sortViewController sortedTitle]];
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
  NSInteger count = [self.tasks count];
  return count;
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
  
  Task *task = [self.tasks objectAtIndex:indexPath.row];
  cell.task = task;
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ 
  TaskCell *cell = (TaskCell*)[self.tableView cellForRowAtIndexPath:indexPath];
  Task *clickedTask = [self.tasks objectAtIndex:indexPath.row];
  
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
    [controller loadTask:clickedTask editing:NO positionInList:[indexPath row] ofTotalCount:[self.tasks count]];
    
    [self.navigationController pushViewController:controller animated:YES];    
  }
  
  return nil;
}

- (IBAction)archiveTasks:(id)sender
{
  NSMutableArray *archivedPaths = [NSMutableArray arrayWithCapacity:[self.tasks count]];
  for (NSInteger i = 0; i < [self.tasks count]; i++)
  {
    Task* task = [self.tasks objectAtIndex:i];
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
    self.tasks = nil;
    
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


- (void)dealloc
{
  [tableView release];
  [taskList release];
  [tasks release];
  [taskViewController release];
  [sortViewController release];
  [super dealloc];
}

@end
