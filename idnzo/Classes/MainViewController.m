
#import "MainViewController.h"

@interface MainViewController ()

- (void) loadListViewForList:(TaskList*)list;
- (void) loadListViewForList:(TaskList*)list animated:(BOOL)animated;
- (void) recordViewedList:(NSObject*)object;
- (void) loadLastViewedList:(NSObject*)object;

@end

@implementation MainViewController

@synthesize taskLists;
@synthesize listViewController;

- (void)viewDidLoad
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *listName = [defaults objectForKey:@"lastListViewed"];
  NSLog(@"Last viewed list was %@", listName);
  if (listName != nil)
  {
    [self loadLastViewedList:listName];
  }
  
  UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self action:@selector(onClickAddList:)];
  self.navigationItem.rightBarButtonItem = add;
  [add release];
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self
          selector:@selector(donzoDataUpdated:) 
              name:DonezoDataUpdatedNotification
            object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self recordViewedList:nil];
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


- (void) loadLastViewedList:(NSObject*)object
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  request.entity = [NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:appDelegate.managedObjectContext];
  [request setPredicate:[NSPredicate predicateWithFormat:@"name = %@", object]];
  
  NSError *error = nil;
  NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
  if (error == nil && [results count] > 0)
  {
    [self loadListViewForList:[results objectAtIndex:0] animated:NO];
  }
  else
  {
    NSLog(@"Couldn't load list view for list with name %@!", object);
  }
}

- (void) recordViewedList:(NSObject*)object
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:object forKey:@"lastListViewed"];
}

- (void) loadListViewForList:(TaskList*)list animated:(BOOL)animated
{
  self.listViewController.taskList = list;
  
  [self recordViewedList:[list name]];
  
  [self.navigationController pushViewController:self.listViewController animated:animated];
}
- (void) loadListViewForList:(TaskList*)list
{
  [self loadListViewForList:list animated:YES];
}


- (void) onClickAddList:(id)sender
{
  TextFieldViewController *tfvc = [[TextFieldViewController alloc] initWithNibName:@"TextFieldView" bundle:nil];
  
  tfvc.title = @"Add Task List";
  tfvc.placeholder = @"New Task List";
  tfvc.saveAction = @selector(addList:);
  tfvc.target = self;
  
  UINavigationController *modalNavigationController =
    [[[UINavigationController alloc] initWithRootViewController:tfvc] autorelease];
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];  
}

- (void) addList:(id)sender
{
  TextFieldViewController *tfvc = (TextFieldViewController*)sender;
  NSString *name = [tfvc.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSLog(@"Adding new list with name %@", name);
  
  if ([name isEqualToString:@""])
  {
    // Empty string
    return;
  }
  
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = appDelegate.managedObjectContext;
  TaskList *newList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:context];
  newList.name = name;
  
  NSError *error;
  if (![context save:&error])
  {
    NSLog(@"Error saving new task list with name %@ and error %@", name, [error localizedDescription]);
  }
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc postNotificationName:DonezoDataUpdatedNotification object:self];
  [dnc postNotificationName:DonezoShouldSyncNotification object:self];
}

- (void) donzoDataUpdated:(NSNotification*)notification
{
  // NSLog(@"MainViewController: Handled updated data.");
  self.taskLists = nil;
  [self.tableView reloadData];
}

- (NSArray *) taskLists
{
  if (taskLists == nil)
  {
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
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
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyIdentifier"] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  TaskList *taskList = [self.taskLists objectAtIndex:indexPath.row];
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
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  TaskList *clickedList = [self.taskLists objectAtIndex:indexPath.row];

  [self loadListViewForList:clickedList];
  
  return nil;
}


- (void) dealloc
{
  [taskLists release];
  [listViewController release];
  [super dealloc];
}

@end
