//
//  DNZOAppDelegate.m
//  DNZO
//
//  Created by Taylor Hughes on 4/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "DNZOAppDelegate.h"

@interface DNZOAppDelegate (Private)
- (void)createInitialObjects;
@end

@implementation DNZOAppDelegate

BOOL firstRun;

@synthesize window, navigationController, mainController;

- (id) init
{
  self = [super init];
  if (self != nil)
  {
    // Re-set by persistent store coordinator
    firstRun = NO;
  }
  return self;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application
{  
  self.mainController.managedObjectContext = [self managedObjectContext];
  
  if (firstRun)
  {
    [self createInitialObjects];
  }
  
  // Add the current view in the navigationController to the main window.
  [window addSubview:navigationController.view];
  [window makeKeyAndVisible];
}

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender
{
  NSError *error;
  if (![[self managedObjectContext] save:&error])
  {
    // Handle error
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
  if (managedObjectContext != nil)
  {
    return managedObjectContext;
  }
	
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil)
  {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{
  if (managedObjectModel != nil)
  {
    return managedObjectModel;
  }
  managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
  return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator != nil)
  {
    return persistentStoreCoordinator;
  }
	
  NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"donezo.sqlite"];
  NSURL *storeUrl = [NSURL fileURLWithPath:path];
	firstRun = ![[NSFileManager defaultManager] fileExistsAtPath:path];
  
	NSError *error;
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
  {
    // Handle error
  }
	
  return persistentStoreCoordinator;
}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
}

- (void)createInitialObjects
{   
  NSLog(@"Adding TaskList...");
  
  TaskList *list = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext];
  
  list.name = @"Tasks";
  
  NSLog(@"Adding task...");
  
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
  
  NSError *error;
  [self.managedObjectContext save:&error];
}

// Save all changes to the database, then close it.
- (void)applicationWillTerminate:(UIApplication *)application
{
  NSError *error;
  if (managedObjectContext != nil)
  {
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
  [navigationController release];
  [window release];
  [super dealloc];
}


@end
