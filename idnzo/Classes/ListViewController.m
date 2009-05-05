
#import "ListViewController.h"

@implementation ListViewController

@synthesize tableView;
@synthesize taskList;
@synthesize tasks;
@synthesize editViewController;

- (EditViewController *)editViewController {
  // Instantiate the detail view controller if necessary.
  if (editViewController == nil) {
    editViewController = [[EditViewController alloc] initWithNibName:@"EditView" bundle:nil];
  }
  return editViewController;
}

- (void)setTaskList:(TaskList *)list {
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

- (NSArray *)tasks {
  if (!tasks) {
    tasks = [[taskList findRelated:[Task class]]  retain];
  }
  return tasks;
}

- (void)viewWillAppear:(BOOL)animated {
  NSLog(@"Reloading data...");
  [tableView reloadData];
}

// This table will always only have one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
  return 1;
}

// One row per book, the number of books is the number of rows.
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
  return [self.tasks count];
}

// The accessory type is the image displayed on the far right of each table cell. In order for the delegate method
// tableView:accessoryButtonClickedForRowWithIndexPath: to be called, you must return the "Detail Disclosure Button" type.
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//  return UITableViewCellAccessoryDisclosureIndicator;
//}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
  if (cell == nil) {
    // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
  }
  
  Task *task = [self.tasks objectAtIndex:indexPath.row];
  NSLog(@"Setting task body...");
  cell.text = task.body;
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  EditViewController *controller = self.editViewController;
  
  Task *clickedTask = [self.tasks objectAtIndex:indexPath.row];
  controller.task = clickedTask;
  
  [self.navigationController pushViewController:controller animated:YES];
  
  return nil;
}

- (void)dealloc {
  [tableView release];
  [taskList release];
  [tasks release];
  [editViewController release];
  [super dealloc];
}

@end
