#import "MainViewController.h"
#import "ListViewController.h"

@interface MainViewController ()

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, retain) UITableView *tableView;

@end

@implementation MainViewController

@synthesize tableView;
@synthesize listViewController, navigationController;

@synthesize taskLists;

- (ListViewController *)listViewController {
  // Instantiate the detail view controller if necessary.
  if (listViewController == nil) {
    listViewController = [[ListViewController alloc] initWithNibName:@"ListView" bundle:nil];
  }
  return listViewController;
}

- (NSArray *) taskLists {
  if (taskLists == nil) {
    taskLists = [TaskList findAll];
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
  
  TaskList *taskList = [taskLists objectAtIndex:indexPath.row];
  cell.text = taskList.name;
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Inspect the book (method defined above).
  //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  //Book *book = [appDelegate.books objectAtIndex:indexPath.row];
  
  ListViewController *controller = self.listViewController;
  
  // Set the detail controller's inspected item to the currently-selected book.
  controller.contents = [NSString stringWithFormat:@"You clicked %d", indexPath.row];
                         
  // "Push" the detail view on to the navigation controller's stack.
  [self.navigationController pushViewController:controller animated:YES];
  //[controller setEditing:NO animated:NO];
  
  return nil;
}

@end
