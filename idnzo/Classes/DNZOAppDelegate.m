//
//  DNZOAppDelegate.m
//  DNZO
//
//  Created by Taylor Hughes on 4/26/09.
//  Copyright Two-Stitch Software 2009. All rights reserved.
//

#import "DNZOAppDelegate.h"

NSString* const DonezoShouldSyncNotification         = @"DonezoShouldSyncNotification";
NSString* const DonezoSyncStatusChangedNotification  = @"DonezoSyncStatusChangedNotification";
NSString* const DonezoShouldResetAndSyncNotification = @"DonezoShouldResetAndSyncNotification";
NSString* const DonezoShouldResetNotification        = @"DonezoShouldResetNotification";
NSString* const DonezoDataUpdatedNotification        = @"DonezoDataUpdatedNotification";
NSString* const DonezoShouldFilterListNotification   = @"DonezoShouldFilterListNotification";
NSString* const DonezoShouldSortListNotification     = @"DonezoShouldSortListNotification";
NSString* const DonezoShouldToggleCompletedTaskNotification = @"DonezoShouldToggleCompletedTaskNotification";


@interface DNZOAppDelegate ()

- (void) firstRun;
- (void) passwordReset;

- (void) createInitialObjects;
- (void) createSyncMaster;

- (void) onSyncEvent:(NSNotification*)syncNotification;
- (void) onResetAndSyncEvent:(NSNotification*)syncNotification;
- (void) onResetEvent:(NSNotification*)syncNotification;

- (void) sync;
- (void) sync:(TaskList*)list;
- (void) syncOperation:(NSObject*)object;
- (NSString*) operationIdentifierForListOrNil:(TaskList*)list;

@property (nonatomic, readonly) NSString *storePath;
@property (nonatomic, retain) DonezoSyncMaster *syncMaster;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end


@implementation DNZOAppDelegate

@synthesize window, navigationController, mainController;

@synthesize operationQueue;

@synthesize syncMaster;
@synthesize donezoAPIClient;

@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator;

- (id) init
{
  self = [super init];
  if (self != nil)
  {
    networkIndicatorShown = 0;
    hasDisplayedError = NO;
    syncOperations = [[NSMutableDictionary alloc] init];
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    [self.operationQueue release];
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    
    [dnc addObserver:self
            selector:@selector(onSyncEvent:) 
                name:DonezoShouldSyncNotification
              object:nil];
    [dnc addObserver:self
            selector:@selector(onResetAndSyncEvent:) 
                name:DonezoShouldResetAndSyncNotification
              object:nil];
    [dnc addObserver:self
            selector:@selector(onResetEvent:) 
                name:DonezoShouldResetNotification
              object:nil];
    
    NSLog(@"SQLite store: %@", self.storePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.storePath])
    {
      NSLog(@"Store does not exist. Adding initial objects...");
      [self firstRun];
    }
  }
  return self;
}

- (BOOL) waitForSyncToFinishAndReinitializeDatastore
{
  BOOL success = YES;
  NSLog(@"Waiting for operations to finish..");
  [self.operationQueue waitUntilAllOperationsAreFinished];
  
  NSLog(@"Finished waiting to finish..");
  @synchronized (self) {
    [self.operationQueue setSuspended:YES];
    
    NSLog(@"Resetting ojects..");    
    self.persistentStoreCoordinator = nil;
    self.managedObjectModel = nil;
    self.managedObjectContext = nil;
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.storePath error:&error];
    if (error)
    {
      NSLog(@"Could not delete the SQLite store! %@ (%@)", [error description], [error userInfo]);
      success = NO;
    }
    else
    {
      [self createInitialObjects];
    }
    
    NSLog(@"Unsuspending queue...");
    [self.operationQueue setSuspended:NO];
  }
  
  //
  // Empty out old data from other views, etc.
  //
  [[NSNotificationCenter defaultCenter] postNotificationName:DonezoDataUpdatedNotification
                                                      object:self];
  
  return success;
}

- (void) onSyncEvent:(NSNotification*)syncNotification
{
  TaskList *list = [[syncNotification userInfo] valueForKey:@"list"];
  NSNumber *userForced = [[syncNotification userInfo] valueForKey:@"userForced"];
  
  if (userForced && [userForced intValue] == 1)
  {
    // This will cause an error to be shown again if the sync fails, since the user requested it
    hasDisplayedError = NO;
  }
  
  [self sync:list];
}


- (void) onResetEvent:(NSNotification*)syncNotification
{
  @synchronized (self) {
    // This will stop soon after cancel is fired
    [self.syncMaster cancel];
    
    self.donezoAPIClient = nil;
    self.syncMaster = nil;
    
    hasDisplayedError = NO;
  }
}
- (void) onResetAndSyncEvent:(NSNotification*)syncNotification
{
  [self onResetEvent:syncNotification];
  [self sync];
}

- (void) createSyncMaster
{
  NSString *donezoUsername = [SettingsHelper username];
  NSString *donezoPassword = [SettingsHelper password];
  NSString *donezoURL =      [SettingsHelper URL];
  
  NSLog(@"## Setting up to sync user %@ to URL %@ ##", donezoUsername, donezoURL);
  self.donezoAPIClient = [[[DonezoAPIClient alloc] initWithUsername:donezoUsername 
                                                        andPassword:donezoPassword
                                                          toBaseUrl:donezoURL] autorelease];
  
  self.syncMaster = [[[DonezoSyncMaster alloc] initWithDonezoClient:self.donezoAPIClient 
                                                        andContext:nil] autorelease];
}

#define SYNC_ALL_IDENTIFIER @"syncAll"
- (NSString*) operationIdentifierForListOrNil:(TaskList*)list
{
  if (list && list.key)
  {
    return [NSString stringWithFormat:@"syncList:%@", list.key];
  }
  return SYNC_ALL_IDENTIFIER;
}

- (BOOL) isSyncing:(TaskList*)list
{
  NSNumber *allCount =  [syncOperations objectForKey:SYNC_ALL_IDENTIFIER];
  NSNumber *listCount = [syncOperations objectForKey:[self operationIdentifierForListOrNil:list]];
  
  return [allCount intValue] > 0 || [listCount intValue] > 0;
}

- (void) sync
{
  [self sync:nil];
}
- (void) sync:(TaskList*)list
{
  if (![SettingsHelper canSync])
  {
    NSLog(@"Ignoring new sync request.");
    return;
  }
  
  //
  // Pause operation queue for now 
  //
  [self.operationQueue setSuspended:YES];
  
  if (!list.key)
  {
    list = nil;
  }
  NSString *identifier = [self operationIdentifierForListOrNil:list];
  
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
    
    NSNumber *number = [syncOperations objectForKey:identifier];
    if (!number)
    {
      number = [NSNumber numberWithInt:0];
    }
    [syncOperations setValue:[NSNumber numberWithInt:([number intValue] + 1)] forKey:identifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:DonezoSyncStatusChangedNotification object:nil];
    
    [self.operationQueue addOperation:syncOperation];
    [syncOperation release];    
  }
  
  [self.operationQueue setSuspended:NO];
}

- (void) synchronouslySyncAll
{
  [self syncOperation:nil];
}

- (void) syncOperation:(NSObject*)object
{
  //
  // WARNING: Operates in a separate thread, do not make non-threadsafe calls here!
  //
  if (![SettingsHelper canSync])
  {
    NSLog(@"Sync is no longer enabled or no username or password; returning.");
    return;
  }
  
  DonezoSyncMaster *master;
  @synchronized (self) {
    if (!self.syncMaster)
    {
      [self createSyncMaster];
    }
    master = [self.syncMaster retain];
  }
  
  [self showNetworkIndicator];
  
  master.context = [[[NSManagedObjectContext alloc] init] autorelease];
  [master.context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self
          selector:@selector(contextDidSave:) 
              name:NSManagedObjectContextDidSaveNotification
            object:nil];
    
  NSError *error = nil;
  
  TaskList *list = nil;
  if (object != nil)
  {
    list = (TaskList*)object;
    list = (TaskList*)[master.context objectWithID:[list objectID]];
  }
  NSString *identifier = [self operationIdentifierForListOrNil:list];
  
  // Make sure we can login first before setting the sync'd username
  if ([self.donezoAPIClient login:&error])
  {
    [SettingsHelper setSyncedUsername:[SettingsHelper username]];
    
    if (list == nil)
    {
      [master syncAll:&error];
    }
    else
    {
      [master syncList:list error:&error];
    }
  }
  
  [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
  [master release];
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
  [dict setValue:error      forKey:@"error"];
  [dict setValue:identifier forKey:@"identifier"];
  [self performSelectorOnMainThread:@selector(finishSync:) withObject:dict waitUntilDone:YES];
}

- (void) contextDidSave:(NSNotification*)saveNotification
{
  [self performSelectorOnMainThread:@selector(mergeChangesForAllContexts:) 
                         withObject:saveNotification
                      waitUntilDone:YES];
}

- (void) mergeChangesForAllContexts:(id)obj
{
  NSNotification *saveNotification = (NSNotification*)obj;
  [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
  [self.syncMaster.context mergeChangesFromContextDidSaveNotification:saveNotification];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DonezoDataUpdatedNotification
                                                      object:self];
}

// Operates on the main thread
- (void) finishSync:(id)arg
{
  NSDictionary *dict   = (NSDictionary*)arg;
  NSError *error       = (NSError*)[dict valueForKey:@"error"];
  NSString *identifier = (NSString*)[dict valueForKey:@"identifier"];
  
  [self hideNetworkIndicator];
  
  if (error != nil)
  {
    NSLog(@"Error syncing! %@ %@", [error description], [error userInfo]);
    
    if (!hasDisplayedError)
    {
      NSString *errorDescription = [[error localizedDescription] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      if ([errorDescription length] > 0)
      {
        // Capitalize first letter
        errorDescription = [errorDescription stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                     withString:[[errorDescription substringToIndex:1]
                                                                                 capitalizedString]];
        // Ensure it ends with some kind of punctuation, if not end a period
        NSString *lastCharacter = [errorDescription substringFromIndex:([errorDescription length] - 1)];
        if ([[lastCharacter stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]] length] > 0)
        {
          errorDescription = [errorDescription stringByAppendingString:@"."];
        }
      }
      else
      {
        errorDescription = @"An unknown error has occurred.";
      }

      UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Done-zo sync error"
                                                           message:errorDescription
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
      [errorAlert show];
      [errorAlert release];
      
      hasDisplayedError = YES;
    }
  }
  else
  {
    NSLog(@"Sync completed successfully!");
  }

  NSNumber *num = [syncOperations objectForKey:identifier];
  [syncOperations setValue:[NSNumber numberWithInt:([num intValue] - 1)] forKey:identifier];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DonezoSyncStatusChangedNotification
                                                      object:self
                                                    userInfo:nil];
}

- (void) showNetworkIndicator
{
  @synchronized (self) {
    if (networkIndicatorShown++ <= 0)
    {
      UIApplication* app = [UIApplication sharedApplication];
      app.networkActivityIndicatorVisible = YES;
    }
  }
}
- (void) hideNetworkIndicator
{
  @synchronized (self) {
    if (--networkIndicatorShown <= 0)
    {
      UIApplication* app = [UIApplication sharedApplication];
      app.networkActivityIndicatorVisible = NO;
    }
  }
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
  [self sync];

  // Add the current view in the navigationController to the main window.
  [window addSubview:navigationController.view];
  [window makeKeyAndVisible];

  // Just do this once when the app is loaded.
  if ([SettingsHelper isSyncEnabled] && [SettingsHelper hasUsername] && ![SettingsHelper hasPassword])
  {
    // Password can be removed from the keychain after upgrading in certain
    // circumstances; prompt them to re-enter.
    [self passwordReset];
  }
}

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction) saveAction:(id)sender
{
  NSError *error = nil;
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Tasks" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
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
    NSError *error = nil;
    NSURL *storeUrl = [NSURL fileURLWithPath:self.storePath];

    // Enables automatic migration to the updated datamodel.
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                               [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                               nil];

    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
    {
      NSLog(@"Could not initialize persistentStoreCoordinator: %@ %@", [error description], [error userInfo]);
    }
  }
    
  return persistentStoreCoordinator;
}

//
// Returns the path to the application's SQLite datastore.
//
- (NSString *)storePath
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  
  return [basePath stringByAppendingPathComponent:@"donezo.sqlite"];
}


- (void) firstRun
{
  [self createInitialObjects];
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to Done-zo!"
                                                  message:@"We can synchronize your task lists\n"
                                                           "with Done-zo.com using your\n"
                                                           "Google Account. Do you want\n"
                                                           "to set this up?"
                                                 delegate:self
                                        cancelButtonTitle:@"No thanks"
                                        otherButtonTitles:@"Set up sync",nil];
  [alert show];
  [alert release];
}

- (void) passwordReset
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome back to Done-zo!"
                                                  message:@"Please re-enter your password,\n"
                                                           "it may have been lost during\n"
                                                           "an upgrade."
                                                 delegate:self
                                        cancelButtonTitle:@"Later"
                                        otherButtonTitles:@"Set up sync",nil];
  [alert show];
  [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1)
  {
    // Set up sync: Show settings page in a modal view
    SettingsViewController *settings = [SettingsViewController settingsViewControllerWithSyncEnabled];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settings];
    
    [self.navigationController presentModalViewController:settingsNav animated:YES];
    
    [settingsNav release];
  }
}


- (void) createInitialObjects
{   
  TaskList *list = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext];
  
  list.name = @"Tasks";
  
  Project *project = (Project*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
  project.name = @"Done-zo";
  
  Context *context = (Context*)[NSEntityDescription insertNewObjectForEntityForName:@"Context" inManagedObjectContext:self.managedObjectContext];
  context.name = @"home";
  
  Task *task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
  
  task.taskList = list;
  task.body = @"Welcome to Done-zo iPhone!";
  
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
  
  [SettingsHelper setLastViewedList:list];
}

// Save all changes to the database, then close it.
- (void)applicationWillTerminate:(UIApplication *)application
{
  if (managedObjectContext != nil)
  {
    NSError *error = nil;
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
  [syncOperations release];
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
