//
//  DNZOAppDelegate.m
//  DNZO
//
//  Created by Taylor Hughes on 4/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "DNZOAppDelegate.h"

static NSString *DATABASE_FILENAME     = @"dnzo.sqlite";

@interface DNZOAppDelegate (Private)
- (void) openDatabase;
- (void) createInitialObjects;
@end

@implementation DNZOAppDelegate

@synthesize window, navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  [self openDatabase];
  [self createInitialObjects];
  
  // Add the current view in the navigationController to the main window.
  [window addSubview:navigationController.view];
  [window makeKeyAndVisible];
}

- (void)dealloc {
  [navigationController release];
  [window release];
  [super dealloc];
}

- (void)openDatabase {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILENAME];
  
  [[SQLiteInstanceManager sharedManager] setDatabaseFilepath:databasePath];
}

- (void)createInitialObjects {
  if ([TaskList count] > 0) {
    return;
  }
  
  /*
  NSLog(@"Deleting existing items...");
  for (TaskList *taskList in [TaskList allObjects]) {
    [taskList deleteObject];
  }
  for (Task *task in [Task allObjects]) {
    [task deleteObject];
  }
  */
  
  NSLog(@"Adding TaskList...");
  
  TaskList *list = [[[TaskList alloc] init] autorelease];
  
  [list setName:@"Tasks"];
  [list save];
  
  NSLog(@"Adding task...");
  
  Task *task = [[[Task alloc] init] autorelease];
  task.taskList = list;
  task.body = @"Welcome to DNZO!";
  task.contexts = [NSArray arrayWithObject:@"home"];
  task.project = @"DNZO";
  task.due = [NSDate dateWithTimeIntervalSinceNow:0];
  
  [task save];
}

// Save all changes to the database, then close it.
- (void)applicationWillTerminate:(UIApplication *)application {

}

@end
