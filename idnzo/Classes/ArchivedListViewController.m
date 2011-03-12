//
//  ArchivedListViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 11/14/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "ArchivedListViewController.h"

@interface ArchivedListViewController (Private)

- (void) showLoadingIndicator;
- (void) hideLoadingIndicator;

@end

@implementation ArchivedListViewController

@synthesize localTasks, remoteTasks;

@synthesize start, end;

@synthesize tableView;
@synthesize loadingView;

@synthesize currentOperation, queue;


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  loadingIndicatorShown = 0;
  
  self.loadingView.hidden = YES;
  
  self.queue = [[NSOperationQueue alloc] init];
  [self.queue release];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.navigationItem.title = @"Archived Tasks";
  
  NSLog(@"Showing archived tasks for %@ to %@",
        [DonezoDates donezoDetailedDateStringFromDate:self.start], 
        [DonezoDates donezoDetailedDateStringFromDate:self.end]);
  
  self.localTasks = nil;
  self.remoteTasks = nil;
  
  [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}


- (void) showLoadingIndicator
{
  @synchronized (self)
  {
    if (loadingIndicatorShown++ >= 0)
    {
      [self performSelectorOnMainThread:@selector(showLoadingView) withObject:nil waitUntilDone:YES];
    }    
  }
  [(DNZOAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkIndicator];
}
- (void) hideLoadingIndicator
{
  @synchronized (self)
  {
    if (--loadingIndicatorShown <= 0)
    {
      [self performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:YES];
    }
  }
  [(DNZOAppDelegate *)[[UIApplication sharedApplication] delegate] hideNetworkIndicator];
}
- (void) showLoadingView
{
  self.loadingView.hidden = NO;
}
- (void) hideLoadingView
{
  self.loadingView.hidden = YES;
}

- (NSArray*) localTasks
{
  if (!localTasks)
  {
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *substitutions = [[NSMutableDictionary alloc] initWithCapacity:2];
    [substitutions setValue:self.start forKey:@"start"];
    [substitutions setValue:self.end   forKey:@"end"];
    
    NSFetchRequest *fetchRequest = [appDelegate.managedObjectModel fetchRequestFromTemplateWithName:@"archivedTasks"
                                                                              substitutionVariables:substitutions];
    
    NSError *error = nil;
    self.localTasks = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil)
    {
      NSLog(@"Error fetching local tasks! %@ %@", [error description], [error userInfo]);
      self.localTasks = [NSArray array];
    }
    else
    {
      NSLog(@"Fetched %d local archived tasks.", [self.localTasks count]);
    }
  }
  
  return localTasks;
}

- (void) loadRemoteTasks
{
  void *operation = currentOperation;
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  [self showLoadingIndicator];
  
  NSError *error =  nil;
  NSArray *tasks =  [appDelegate.donezoAPIClient getArchivedTasksCompletedBetweenDate:self.start
                                                                              andDate:self.end
                                                                                error:&error];

  [self hideLoadingIndicator];
  
  if (error != nil)
  {
    NSLog(@"Error fetching remote archived tasks! WTFOMG, %@", [error localizedDescription]);
  }
  else if (operation != currentOperation)
  {
    NSLog(@"Whoops, operation has changed since the request was made. Forget about it.");
  }
  else
  {
    // Success!
    NSLog(@"Fetched %d remote archived tasks", [tasks count]);
    [self performSelectorOnMainThread:@selector(showRemoteTasks:) withObject:tasks waitUntilDone:YES];
  }
}

- (void) showRemoteTasks:(id)tasks
{
  self.remoteTasks = (NSArray*)tasks;
  [self.tableView reloadData];
}

- (NSArray*) remoteTasks
{
  if (!remoteTasks && [SettingsHelper canSync])
  {
    @synchronized(self)
    {
      self.remoteTasks = [NSArray array];
      self.currentOperation = [[[NSInvocationOperation alloc] initWithTarget:self 
                                                                    selector:@selector(loadRemoteTasks)
                                                                      object:nil] autorelease];
      [self.queue addOperation:self.currentOperation];
    }
  }
  
  return remoteTasks;
}

// Static function for comparing task objects, Task*/DonezoTask* agnostic
static NSInteger compareLocalRemoteTasks(id a, id b, void *context)
{
  NSDate *da, *db = nil;
  
  da = (NSDate*)[a performSelector:@selector(completedAt)];
  db = (NSDate*)[b performSelector:@selector(completedAt)];
  
  // negative to reverse sort
  return -[da compare:db];
}

- (NSArray*)allTasks
{
  // Just guessting at a reasonable array size here
  NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:50] autorelease];
  
  NSMutableSet *keys = [[NSMutableSet alloc] initWithCapacity:[self.localTasks count]];

  [array addObjectsFromArray:self.localTasks];
  for (Task* task in self.localTasks)
  {
    if (task.key != nil)
    {
      // task.key is a _PFCachedNumber, not an NSNumber derivative; 
      // in order to make the NSSet member/hash functionality work properly
      // they need to be properly comparable.
      NSNumber *key = [[NSNumber alloc] initWithInt:[task.key intValue]];
      [keys addObject:key];
      [key release];
    }
  }
  for (DonezoTask* task in self.remoteTasks)
  {
    if (![keys member:task.key])
    {
      [array addObject:task];
    }
  }
  
  [array sortUsingFunction:compareLocalRemoteTasks context:nil];
  
  return array;
}

#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [TaskCellView height];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[self allTasks] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TaskCell *cell = (TaskCell*)[self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
  if (cell == nil)
  {
    cell = [[[TaskCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  NSObject *obj = [[self allTasks] objectAtIndex:[indexPath row]];
  if ([obj isKindOfClass:[DonezoTask class]])
  {
    [cell displayRemoteTask:(DonezoTask*)obj];
  }
  else if ([obj isKindOfClass:[Task class]])
  {
    [cell displayLocalTask:(Task*)obj archived:YES];
  }
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [@"Tasks Completed " stringByAppendingString:self.title];
}




- (void)dealloc
{
  [queue release];
  [currentOperation release];
  
  [localTasks release];
  [remoteTasks release];
  
  [start release];
  [end release];
  
  [loadingView release];
  [tableView release];
  
  [super dealloc];
}


@end

