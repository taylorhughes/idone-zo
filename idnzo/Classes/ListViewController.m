
#import "ListViewController.h"

@interface ListViewController ()
- (void)newTaskDismissed;
@end

@implementation ListViewController

@synthesize tableView;
@synthesize taskList;
@synthesize tasks;
@synthesize taskViewController;
@synthesize managedObjectContext;

- (TaskViewController *)taskViewController
{
  // Instantiate the detail view controller if necessary.
  if (taskViewController == nil)
  {
    taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskView" bundle:nil];
  }
  return taskViewController;
}

- (void)setTaskList:(TaskList *)list
{
  if (taskList) {
    [taskList release];
  }
  if (tasks) {
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
    tasks = [[[taskList tasks] allObjects] retain];
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
    //[clickedTask save];
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

- (void)addNewTask:(id)sender
{
  EditViewController *controller = [[[EditViewController alloc] initWithNibName:@"EditTaskView" bundle:nil] autorelease];
  
  Task *task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
  task.taskList = self.taskList;
  controller.task = task;
  [task release];
  
  UINavigationController *modalNavigationController = [EditViewController navigationControllerWithTask:controller.task
                                                                                         dismissTarget:self  
                                                                                         dismissAction:@selector(newTaskDismissed)];
  
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];
}

- (void)newTaskDismissed
{
  tasks = nil;
  [tableView reloadData];
}

- (void)dealloc {
  [tableView release];
  [taskList release];
  [tasks release];
  [taskViewController release];
  [managedObjectContext release];
  [super dealloc];
}

@end
