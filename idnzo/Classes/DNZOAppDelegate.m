//
//  DNZOAppDelegate.m
//  DNZO
//
//  Created by Taylor Hughes on 4/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "DNZOAppDelegate.h"

NSString* const DonezoShouldSyncNotification = @"DonezoShouldSyncNotification";

@interface DNZOAppDelegate ()

- (void)createInitialObjects;

- (void) onSyncEvent:(NSNotification*)syncNotification;

- (void) sync;
- (void) sync:(TaskList*)list;

@property (nonatomic, readonly) NSString *storePath;

@property (nonatomic, retain) DonezoAPIClient *donezoAPIClient;
@property (nonatomic, retain) DonezoSyncMaster *syncMaster;

@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end


@implementation DNZOAppDelegate

@synthesize window, navigationController, mainController;

@synthesize operationQueue;

@synthesize syncMaster;
@synthesize donezoAPIClient;

- (id) init
{
  self = [super init];
  if (self != nil)
  { 
    self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self
            selector:@selector(onSyncEvent:) 
                name:DonezoShouldSyncNotification
              object:nil];
    
    // settings holder
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"SQLite store: %@", self.storePath);
    BOOL resetOnLaunch = [defaults boolForKey:@"resetOnLaunch"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.storePath];
    if (resetOnLaunch && fileExists)
    {
      NSError *error = nil;
      [[NSFileManager defaultManager] removeItemAtPath:self.storePath error:&error];
      if (error)
      {
        NSLog(@"Could not delete the SQLite store! %@ (%@)", [error description], [error userInfo]);
      }
      else
      {
        fileExists = NO;
      }
      
      [defaults setBool:NO forKey:@"resetOnLaunch"];
    }
    if (!fileExists)
    {
      NSLog(@"Store does not exist. Adding initial objects...");
      [self createInitialObjects];
    }
  }
  return self;
}

- (void) onSyncEvent:(NSNotification*)syncNotification
{
  TaskList *list = [[syncNotification userInfo] valueForKey:@"list"];
  [self sync:list];
}

- (void) sync
{
  [self sync:nil];
}
- (void) sync:(TaskList*)list
{ 
  [self.operationQueue setSuspended:YES];
  NSString *identifier = @"syncAll";
  if (list.key != nil)
  {
    identifier = [NSString stringWithFormat:@"syncList:%@", list.key];
  }
  else
  {
    list = nil;
  }
  
  BOOL operationQueued = NO;
  for (DonezoSyncOperation *operation in [self.operationQueue operations])
  {
    if (![operation isExecuting] && [operation.identifier isEqualToString:identifier])
    {
      operationQueued = YES;
      break;
    }
  }

  if (operationQueued)
  {
    NSLog(@"Operation '%@' already enqueued.", identifier);
  }
  else
  {
    NSLog(@"Adding '%@' to operation queue...", identifier);
    
    DonezoSyncOperation *syncOperation = [[DonezoSyncOperation alloc]
                                          initWithTarget:self
                                          selector:@selector(syncOperation:)
                                          object:list];
    syncOperation.identifier = identifier;
    
    [self.operationQueue addOperation:syncOperation];
    [syncOperation release];    
  }
  
  [self.operationQueue setSuspended:NO];
}

- (void) syncOperation:(NSObject*)object
{
  //
  // WARNING: Operates in a separate thread, do not make non-threadsafe calls here!
  //

  UIApplication* app = [UIApplication sharedApplication];
  app.networkActivityIndicatorVisible = YES;
  
  self.syncMaster.context = [[[NSManagedObjectContext alloc] init] autorelease];
  [self.syncMaster.context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
  
  NSError *error = nil;
  
  TaskList *list = nil;
  if (object != nil)
  {
    list = (TaskList*)object;
    list = (TaskList*)[self.syncMaster.context objectWithID:[list objectID]];
  }
  
  if (list == nil)
  {
    [self.syncMaster syncAll:&error];
  }
  else
  {
    [self.syncMaster syncList:list error:&error];
  }

  [self performSelectorOnMainThread:@selector(finishSync:) withObject:error waitUntilDone:YES];
}

// Operates on the main thread
- (void) finishSync:(id)arg
{
  NSError *error = (NSError*)arg;
  
  UIApplication* app = [UIApplication sharedApplication];
  app.networkActivityIndicatorVisible = NO;
  
  if (error != nil)
  {
    NSLog(@"Error syncing! %@ %@", [error description], [error userInfo]);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Done-zo sync error"
                                          message:[error localizedDescription]
                                         delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
  }
  else
  {
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self
            selector:@selector(syncingContextDidSave:) 
                name:NSManagedObjectContextDidSaveNotification
              object:self.syncMaster.context];
    
    if (![self.syncMaster.context save:&error])
    {
      NSLog(@"Error saving synced context! %@ %@", [error description], [error userInfo]);
    }
    else
    {
      NSLog(@"Sync completed successfully!");
    }
    [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.syncMaster.context];
    [self.mainController reloadData];
  }
}

- (void)syncingContextDidSave:(NSNotification*)saveNotification
{
	[self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];	
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{ 
  // settings holder
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSString *donezoUsername = [defaults stringForKey:@"username"];
  NSString *donezoPassword = [defaults stringForKey:@"password"];
  NSString *donezoURL = [defaults stringForKey:@"donezoURL"];
  
  NSLog(@"Got user %@ for URL %@", donezoUsername, donezoURL);
  
  self.donezoAPIClient = [[DonezoAPIClient alloc] initWithUsername:donezoUsername andPassword:donezoPassword toBaseUrl:donezoURL];
  self.syncMaster = [[DonezoSyncMaster alloc] initWithDonezoClient:self.donezoAPIClient andContext:nil];
  
  [self sync];
  
  // Add the current view in the navigationController to the main window.
  [window addSubview:navigationController.view];
  [window makeKeyAndVisible];
}

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction) saveAction:(id)sender
{
  NSError *error;
  if (![self.managedObjectContext save:&error])
  {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    exit(-1);  // Fail
  }
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{
  if (managedObjectContext == nil)
  {	
    NSLog(@"Creating managed object context..");
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
      managedObjectContext = [[NSManagedObjectContext alloc] init];
      [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
  }
  return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{
  if (managedObjectModel == nil)
  {
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
  }
  return managedObjectModel;
}


/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator == nil)
  {    
    NSError *error;
    NSURL *storeUrl = [NSURL fileURLWithPath:self.storePath];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
    {
      NSLog(@"Could not initialize persistentStoreCoordinator: %@ %@", [error description], [error userInfo]);
    }
  }
    
  return persistentStoreCoordinator;
}

/**
 * Returns the path to the application's SQLite datastore.
 */
- (NSString *)storePath
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  
  return [basePath stringByAppendingPathComponent:@"donezo.sqlite"];
}

- (void)createInitialObjects
{   
  NSLog(@"> Adding TaskList...");
  
  TaskList *list = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext];
  
  list.name = @"Tasks";
  
  NSLog(@"> Adding task...");
  
  Project *project = (Project*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
  project.name = @"Done-zo";
  
  Context *context = (Context*)[NSEntityDescription insertNewObjectForEntityForName:@"Context" inManagedObjectContext:self.managedObjectContext];
  context.name = @"home";
  
  Task *task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
  
  task.taskList = list;
  task.body = @"Welcome to Done-zo!";
  
  task.contexts = [NSSet setWithObjects:context, nil];
  task.project = project;
  task.dueDate = [NSDate date];
  
  NSError *error = nil;
  [self.managedObjectContext save:&error];
  if (error != nil)
  {
    NSLog(@"Could not save new list and tasks due to an error! %@ %@", [error description], [error userInfo]);
  }
  else
  {
    NSLog(@"Added new default objects.");
  }
}

// Save all changes to the database, then close it.
- (void)applicationWillTerminate:(UIApplication *)application
{
  if (managedObjectContext != nil)
  {
    NSError *error;
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
    {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
    } 
  }
}

- (void)dealloc
{
  [operationQueue release];
  [donezoAPIClient release];
  [syncMaster release];
  
  [managedObjectContext release];
  [managedObjectModel release];
  [persistentStoreCoordinator release];
  
  [navigationController release];
  [window release];
  [super dealloc];
}


@end
