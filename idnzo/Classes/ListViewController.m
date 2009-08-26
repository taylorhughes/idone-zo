
#import "ListViewController.h"

@interface ListViewController () 

- (void)newTaskSaved;
- (void)newTaskCanceled;
- (void)addingContextDidSave:(NSNotification*)saveNotification;

@property (nonatomic, retain) NSManagedObjectContext *addingContext;

@end

@implementation ListViewController

@synthesize tableView;
@synthesize taskList;
@synthesize tasks;
@synthesize taskViewController;
@synthesize addingContext;

- (TaskViewController *)taskViewController
{
  // Instantiate the detail view controller if necessary.
  if (taskViewController == nil)
  {
    taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil];
  }
  return taskViewController;
}

- (void) reloadData
{
  tasks = nil;
  [self.tableView reloadData];
}

- (void) setTaskList:(TaskList *)list
{
  if (taskList)
  {
    [taskList release];
  }
  if (tasks)
  {
    [tasks release];
    tasks = nil;
  }
  taskList = [list retain];
  self.title = [taskList name];
}

- (NSArray *)tasks
{
  if (!tasks)
  {
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *substitutions = [NSDictionary
                                   dictionaryWithObject:taskList.name
                                   forKey:@"taskListName"];
    
    NSFetchRequest *fetchRequest = [appDelegate.managedObjectModel
                                    fetchRequestFromTemplateWithName:@"tasksForList"
                                               substitutionVariables:substitutions];
    NSError *error = nil;
    tasks = [[[taskList tasks] allObjects] retain]; //[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
      NSLog(@"Error fetching tasks! %@ %@", [error description], [error userInfo]);
      tasks = [NSArray array];
    }
  }
  return tasks;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UIBarButtonItem *add = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                   target:self action:@selector(addNewTask:)] autorelease];
  self.navigationItem.rightBarButtonItem = add;
}

- (void)viewWillAppear:(BOOL)animated
{
  [tableView reloadData];
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
    [self.tableView reloadData];
  }
  else
  {
    TaskViewController *controller = self.taskViewController;
    controller.task = clickedTask;
    
    [self.navigationController pushViewController:controller animated:YES];    
  }
  
  return nil;
}

- (IBAction)archiveTasks:(id)sender
{
}

- (IBAction)sync:(id)sender
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  [appDelegate sync];
  [self reloadData];
}

- (void)addNewTask:(id)sender
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];

	// Create a new managed object context for the new book -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	self.addingContext = [[[NSManagedObjectContext alloc] init] autorelease];
	[self.addingContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
  
  Task *task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.addingContext];
  task.taskList = (TaskList*)[self.addingContext objectWithID:[self.taskList objectID]];
  
  UINavigationController *modalNavigationController = [EditViewController navigationControllerWithTask:task
                                                                                         dismissTarget:self  
                                                                                            saveAction:@selector(newTaskSaved)
                                                                                          cancelAction:@selector(newTaskCanceled)];
  
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];
}

- (void)newTaskSaved
{
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self selector:@selector(addingContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.addingContext];
  
  NSError *error;
  if (![self.addingContext save:&error]) {
    // Update to handle the error appropriately.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }
  [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.addingContext];
  
  self.addingContext = nil;
  [self reloadData];
}

- (void)addingContextDidSave:(NSNotification*)saveNotification
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];	
}

- (void)newTaskCanceled
{
  self.addingContext = nil;
}

- (void)dealloc
{
  [tableView release];
  [taskList release];
  [tasks release];
  [taskViewController release];
  [addingContext release];
  [super dealloc];
}

@end
