//
//  SyncTest.m
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "SyncTest.h"

@implementation SyncTest

@synthesize context;
@synthesize tempPath;
@synthesize client;
@synthesize syncMaster;

- (TaskList *) localListWithKey:(NSString*)key
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.context];;
  request.predicate = [NSPredicate predicateWithFormat:@"key == %@", key];
  
  NSError *error = nil;  
  NSArray *result = [self.context executeFetchRequest:request error:&error];
  return [result objectAtIndex:0];  
}

- (NSArray *) localLists
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.context];
  NSError *error = nil;  
  return [self.context executeFetchRequest:request error:&error];
}

- (void) setUp
{
  NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]] retain];
  
  NSString *filename = [NSString stringWithFormat:@"donezo.%0.4f.sqlite", [NSDate timeIntervalSinceReferenceDate]];
  self.tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
  NSURL *storeUrl = [NSURL fileURLWithPath:self.tempPath];
  //NSLog(@"Store URL: %@", storeUrl);
  
  NSError *error = nil;
  NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
  {
    // Handle error
    NSLog(@"FuuuucK: %@ %@", [error description], [error userInfo]);
  }
  
  self.context = [[NSManagedObjectContext alloc] init];
  [self.context setPersistentStoreCoordinator:persistentStoreCoordinator];
  [self.context save:&error];
  NSAssert(error == nil, @"Error saving persistent store!");
  
  self.client = [[MockDonezoAPIClient alloc] init];
  
  self.syncMaster = [[DonezoSyncMaster alloc] initWithDonezoClient:self.client andContext:self.context];
}

- (void) tearDown
{
  NSError *error = nil;
  [[NSFileManager defaultManager] removeItemAtPath:self.tempPath error:&error];
  NSAssert(error == nil, @"Error unlinking file!");
}

// Makes sure we properly sync remote and local task lists.
//
// Also tests the case where we have a remote list called "Tasks"
// and a local list called "Tasks", and when we sync the first
// time the local app uses the name to reconcile the remote and
// local lists.
//
- (void) testMergeTaskLists
{
  [self.client loadTasksAndTaskLists:@"{ \
    \"task_lists\": [ \
     { \"key\": \"tasks\", \"name\": \"Tasks\" }, \
     { \"key\": \"groceries\", \"name\": \"Groceries\" } \
    ] \
  }"];
  
  TaskList *list = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  list.name = @"Another List";
  list = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  list.name = @"Tasks";
  
  NSError *error = nil;
  
  [self.syncMaster performSync:&error];
  
  NSArray *lists = [client getLists:&error];
  STAssertTrue(error == nil, @"Encountered an error! %@", [error description]);
  STAssertEquals([lists count], (NSUInteger)3, @"Wrong count for remote task lists after sync!");
  
  lists = [self localLists];
  STAssertEquals([lists count], (NSUInteger)3, @"Wrong count for local task lists after sync!");
  
  TaskList *localTasks = [self localListWithKey:@"tasks"];
  STAssertNotNil(localTasks, @"Local tasks should not be nil!");
  STAssertEqualObjects(localTasks.name, @"Tasks", @"Local list should be called Tasks");
}

// Makes sure we properly handle the case when we have new
// tasks both locally and remotely.
//
- (void) testNewTasksRemoteAndLocal
{
}

// Tests to make sure we sync existing tasks to get remote
// changes and that local changes are saved remotely.
//
- (void) testUpdatedTasks
{
}

// Tests to make sure we properly handle the case where
// a task was updated remotely and locally, so we choose the
// latest one.
//
- (void) testUpdatedTasksWithConflict
{
}


@end
