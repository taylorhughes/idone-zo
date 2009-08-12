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

- (void) assertListsSynced:(int)numLists
{
  NSError *error = nil;
  NSArray *remoteLists = [client getLists:&error];
  NSArray *localLists = [self localLists];
  
  STAssertTrue(error == nil, @"Encountered an error! %@", [error description]);
  STAssertEquals([remoteLists count], [localLists count], @"Lists counts differ remotely and locally.");
  STAssertEquals([remoteLists count], (NSUInteger)numLists, @"Lists count is incorrect, should be %d", numLists);
  
  for (DonezoTaskList *remoteList in remoteLists)
  {
    TaskList *match = nil;
    for (TaskList *localList in localLists)
    {
      if ([localList.key isEqualToString:remoteList.key])
      {
        match = localList;
        break;
      }
    }
    STAssertNotNil(match, @"Could not find a matching local list for list %@ (key: %@)", remoteList.name, remoteList.key);
  }
}

- (void) assertTasksSynced:(int)numTasks forListWithKey:(NSString*)key
{
  NSError *error = nil;
  NSArray *remoteTasks = [client getTasksForListWithKey:key error:&error];
  STAssertNil(error, @"There has been an error fetching remote tasks! %@", [error description]);
  NSArray *localTasks = [[[self localListWithKey:key] tasks] allObjects];
  
  STAssertEquals([localTasks count], [remoteTasks count], @"Local and remote task counts for list %@ differ!", key);
  STAssertEquals([localTasks count], (NSUInteger)numTasks, @"Local and remote count should be %d for list %@!", numTasks, key);
  
  for (Task *task in localTasks)
  {
    DonezoTask *match = nil;
    for (DonezoTask *remoteTask in remoteTasks)
    {
      if ([remoteTask.key isEqual:task.key])
      {
        match = remoteTask;
        break;
      }
    }
    STAssertNotNil(match, @"Could not find a matching task with key %@ (body: %@)!", task.key, task.body);
    STAssertEqualObjects(match.body, task.body, @"Bodies differ for task %@ (%@)", task.body, task.key);
    STAssertEqualObjects(match.project, task.project.name, @"Projects differ for task %@ (%@)", match.body, task.key);
    STAssertEqualObjects(match.contexts, [task contextNames], @"Contexts differ for task %@ (%@)", match.body, task.key);
  }
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
  
  TaskList *localTasks = [self localListWithKey:@"tasks"];
  STAssertNotNil(localTasks, @"Local tasks should not be nil!");
  STAssertNotNil(localTasks.key, @"Local tasks should now have a key assigned.");
  STAssertEqualObjects(localTasks.name, @"Tasks", @"Local list should be called Tasks");
  
  [self assertListsSynced:3];
}

// Makes sure we properly handle the case when we have new
// tasks both locally and remotely.
//
// Then, test to make sure we sync existing tasks to get remote
// changes and that local changes are saved remotely.
//
- (void) testNewTasksRemoteAndLocal
{
  [self.client loadTasksAndTaskLists:@"{ \
   \"task_lists\": [ \
     { \"key\": \"tasks\", \"name\": \"Tasks\" }, \
     { \"key\": \"groceries\", \"name\": \"Groceries\" } \
   ], \
   \"tasks\": [ \
     { \"id\": 1, \"body\": \"A remote task in Tasks.\", \"task_list\": \"tasks\" }, \
     { \"id\": 2, \"body\": \"A remote task in Groceries.\", \"task_list\": \"groceries\" }, \
     { \"id\": 3, \"body\": \"A second remote task in Groceries.\", \"task_list\": \"groceries\" } \
   ] \
   }"];
  
  TaskList *anotherList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  anotherList.name = @"Another List";
  
  TaskList *tasksList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  tasksList.name = @"Tasks";
  tasksList.key = @"tasks";
  
  Task *task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
  task.taskList = tasksList;
  task.body = @"A local task in the Tasks list";
  
  task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
  task.taskList = tasksList;
  task.body = @"A local task in the Tasks list that has been deleted remotely!";
  task.key = [NSNumber numberWithInt:4];
  
  task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
  task.taskList = anotherList;
  task.body = @"A task in the Another List list.";
  
  task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
  task.taskList = anotherList;
  task.body = @"A second task in the Another List list.";
  
  NSError *error = nil;
  [self.syncMaster performSync:&error];
 
  [self assertListsSynced:3];
  [self assertTasksSynced:2 forListWithKey:@"groceries"];
  [self assertTasksSynced:2 forListWithKey:@"tasks"];
  // key in this case is just lowercase taskList.name since it's mock donezo api client
  [self assertTasksSynced:2 forListWithKey:@"another list"];

}

// Tests to make sure we properly handle the case where
// a task was updated remotely and locally, so we choose the
// latest one.
//
- (void) testUpdatedTasksWithConflict
{
}


@end
