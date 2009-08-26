
#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, retain) ListViewController *listViewController;

@end

@implementation MainViewController

@synthesize taskLists;
@synthesize listViewController;

- (void) dealloc
{
  [taskLists release];
  [listViewController release];
  [super dealloc];
}

- (ListViewController *)listViewController
{
  // Instantiate the detail view controller if necessary.
  if (listViewController == nil)
  {
    listViewController = [[ListViewController alloc] initWithNibName:@"ListView" bundle:nil];
  }
  return listViewController;
}

- (NSArray *) taskLists
{
  if (taskLists == nil)
  {
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:appDelegate.managedObjectContext];
    request.entity = entity;
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sorters = [NSArray arrayWithObjects:sort, nil];
    request.sortDescriptors = sorters;
    [sort release];
    
    NSError *error;
    
    self.taskLists = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    if (self.taskLists == nil)
    {
      // handle error
      NSLog(@"No task lists, shit!");
    }
  }
  return taskLists;
}

#pragma mark Table Delegate and Data Source Methods
// These methods are all part of either the UITableViewDelegate or UITableViewDataSource protocols.

// This table will always only have one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 1;
}

// One row per book, the number of books is the number of rows.
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
  return [self.taskLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
  if (cell == nil)
  {
    // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  // Retrieve the book object matching the row from the application delegate's array.
  //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  //Book *book = (Book *)[appDelegate.books objectAtIndex:indexPath.row];
  
  TaskList *taskList = [self.taskLists objectAtIndex:indexPath.row];
  cell.textLabel.text = taskList.name;
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  ListViewController *controller = self.listViewController;

  TaskList *clickedList = [self.taskLists objectAtIndex:indexPath.row];
  controller.taskList = clickedList;
  
  [self.navigationController pushViewController:controller animated:YES];
  
  return nil;
}

@end
