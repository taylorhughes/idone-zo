
#import "MainViewController.h"

// Static date range creation

@interface MainViewController ()

- (void) loadListViewForList:(TaskList*)list;
- (void) loadListViewForList:(TaskList*)list animated:(BOOL)animated;
- (void) recordViewedList:(NSObject*)object;
- (void) loadLastViewedList:(NSObject*)object;

@end

@implementation MainViewController

@synthesize taskLists;
@synthesize listViewController;
@synthesize archivedListViewController;

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

- (ArchivedListViewController *)archivedListViewController
{
  // Instantiate the detail view controller if necessary.
  if (archivedListViewController == nil)
  {
    archivedListViewController = [[ArchivedListViewController alloc] initWithStyle:UITableViewStylePlain];
  }
  return archivedListViewController;
}

- (NSArray*)archivedLabels
{
  if (!archivedLabels)
  {
    archivedLabels = [[NSArray alloc] initWithObjects:
                      @"Today",
                      @"Yesterday",
                      @"This Week",
                      @"Last Week",
                      nil];
  }
  return archivedLabels;
}

- (NSArray*)getStartAndEndDatesForArchivedLabelPosition:(NSUInteger)index
{
  NSDate *start = [NSDate date];
  NSDate *end = [NSDate date];
  
  switch (index)
  {
    case 0:
      // Today: midnight this morning to midnight tonight, local time zone
      start = [DonezoDates thisMorningAtMidnight];
      end =   [DonezoDates tonightAtMidnight];
      break;
    case 1:
      // Yesterday: midnight this morning to midnight yesterday morning
      start = [DonezoDates yesterdayMorningAtMidnight];
      end =   [DonezoDates thisMorningAtMidnight];
      break;
    case 2:
      // This Week: midnight this past sunday to midnight next saturday
      start = [DonezoDates beginningOfThisWeek];
      end =   [DonezoDates endOfThisWeek];
      break;
    case 3:
      // Last Week: midnight two sundays ago to midnight this past sunday
      start = [DonezoDates beginningOfLastWeek];
      end =   [DonezoDates beginningOfThisWeek];
      break;
  }
  
  return [NSArray arrayWithObjects:start, end, nil];
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
    // Empty string; should we display an alert or something?
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    // regular lists
    case 0:
      return [self.taskLists count];
    
    // archived tasks
    case 1:
    default:
      return [self.archivedLabels count];
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    // archived tasks
    case 1:
      return @"Archived Tasks";
      
    case 0:
    default:
      return nil;
  }
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
  
  TaskList *taskList = nil;
  switch ([indexPath section])
  {
    case 0:
      taskList = [self.taskLists objectAtIndex:indexPath.row];
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
      break;
      
    // archived tasks
    case 1:
      cell.textLabel.text = [self.archivedLabels objectAtIndex:[indexPath row]];
      // Setting this to an empty string is required to fix a rendering issue in iPhoneOS 3.1.2
      cell.detailTextLabel.text = @"";
      break;
  }
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([indexPath section] == 0)
  {
    TaskList *clickedList = [self.taskLists objectAtIndex:indexPath.row];
    [self loadListViewForList:clickedList];    
  }
  else
  {
    self.archivedListViewController.title = [self.archivedLabels objectAtIndex:[indexPath row]];
    NSArray *range = [self getStartAndEndDatesForArchivedLabelPosition:[indexPath row]];

    self.archivedListViewController.start = [range objectAtIndex:0];
    self.archivedListViewController.end   = [range objectAtIndex:1];
    [self.navigationController pushViewController:self.archivedListViewController animated:YES];
  }

  return nil;
}


- (void) dealloc
{
  [taskLists release];
  [listViewController release];
  [archivedLabels release];
  [archivedRanges release];
  [super dealloc];
}

@end
