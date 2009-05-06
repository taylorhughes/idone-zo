#import "MainViewController.h"
#import "ListViewController.h"

@interface MainViewController ()

@property (nonatomic, retain) ListViewController *listViewController;

@end

@implementation MainViewController

@synthesize taskLists;
@synthesize listViewController;

- (ListViewController *)listViewController {
  // Instantiate the detail view controller if necessary.
  if (listViewController == nil) {
    listViewController = [[ListViewController alloc] initWithNibName:@"ListView" bundle:nil];
  }
  return listViewController;
}

- (NSArray *) taskLists {
  if (taskLists == nil) {
    self.taskLists = [TaskList allObjects];
  }
  return taskLists;
}

#pragma mark Table Delegate and Data Source Methods
// These methods are all part of either the UITableViewDelegate or UITableViewDataSource protocols.

// This table will always only have one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
  return 1;
}

// One row per book, the number of books is the number of rows.
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
  return [self.taskLists count];
}

// The accessory type is the image displayed on the far right of each table cell. In order for the delegate method
// tableView:accessoryButtonClickedForRowWithIndexPath: to be called, you must return the "Detail Disclosure Button" type.
- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellAccessoryDisclosureIndicator;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
  if (cell == nil) {
    // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
  }
  
  // Retrieve the book object matching the row from the application delegate's array.
  //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  //Book *book = (Book *)[appDelegate.books objectAtIndex:indexPath.row];
  
  TaskList *taskList = [self.taskLists objectAtIndex:indexPath.row];
  cell.text = taskList.name;
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  ListViewController *controller = self.listViewController;

  TaskList *clickedList = [self.taskLists objectAtIndex:indexPath.row];
  controller.taskList = clickedList;
  
  [self.navigationController pushViewController:controller animated:YES];
  
  return nil;
}

@end
