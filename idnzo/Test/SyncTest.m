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

- (void) setUp
{
  NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
  
  NSString *filename = [NSString stringWithFormat:@"donezo.%0.4f.sqlite", [NSDate timeIntervalSinceReferenceDate]];
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
  NSURL *storeUrl = [NSURL fileURLWithPath:path];
  NSLog(@"Store URL: %@", storeUrl);
  
  NSError *error;
  NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
  {
    // Handle error
    NSLog(@"FuuuucK: %@ %@", [error description], [error userInfo]);
  }
  
  self.context = [[NSManagedObjectContext alloc] init];
  [self.context setPersistentStoreCoordinator:persistentStoreCoordinator];
  
  [self.context save:&error];
}

- (void) tearDown
{
}

// Makes sure we properly sync remote and local task lists.
//
- (void) testMergeTaskLists
{
}

// Tests the case where we have a remote list called "Tasks"
// and a local list called "Tasks", and when we sync the first
// time the local app uses the name to reconcile the remote and
// local lists.
//
- (void) testReconcileTaskLists
{
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
