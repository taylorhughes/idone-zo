//
//  SyncTest.m
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "SyncTest.h"

@implementation SyncTest

@synthesize context;
@synthesize tempPath;
@synthesize client;
@synthesize syncMaster;

#define TEST_URL      @"http://localhost:8081/"
#define TEST_USER     @"synctest@user.com"
#define TEST_PASSWORD @""

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

- (NSArray *) tasksForList:(TaskList*)taskList
{
  NSDictionary *substitutions = [NSDictionary
                                 dictionaryWithObject:taskList
                                 forKey:@"taskList"];
  NSFetchRequest *fetchRequest = [[[self.context persistentStoreCoordinator] managedObjectModel]
                                  fetchRequestFromTemplateWithName:@"tasksForList"
                                  substitutionVariables:substitutions];
  return [self.context executeFetchRequest:fetchRequest error:nil];
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
    NSLog(@"FuuuucK: %@ %@", [error description], [error userInfo]);
  }
  
  self.context = [[NSManagedObjectContext alloc] init];
  [self.context setPersistentStoreCoordinator:persistentStoreCoordinator];
  [self.context save:&error];
  NSAssert(error == nil, @"Error saving persistent store!");
  
  self.client = [[MockDonezoAPIClient alloc] initWithUsername:TEST_USER andPassword:TEST_PASSWORD toBaseUrl:TEST_URL];
  
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
  NSArray *localTasks = [self tasksForList:[self localListWithKey:key]];
  
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
    
    STAssertEqualObjects(match.body, task.body, @"Bodies differ for task '%@' (%@)", task.body, task.key);
    //NSLog(@"Task project is %@ and %@", match.project, task.project.name);
    STAssertEqualObjects(match.project, task.project.name, @"Projects differ for task '%@' (%@)", match.body, task.key);
    //NSLog(@"Local tasks are: %@", [task contextNames]);
    //NSLog(@"Remote tasks are: %@", match.contexts);
    for (NSString *aContext in match.contexts)
    {
      int index = [[task contextNames] indexOfObject:aContext];
      STAssertTrue(index > -1, @"Contexts differ for task '%@' (%@)", match.body, task.key);
    }
    NSString *a = [NSString stringWithFormat:@"%0.8f", [match.updatedAt timeIntervalSinceReferenceDate]];
    NSString *b = [NSString stringWithFormat:@"%0.8f", [task.updatedAt timeIntervalSinceReferenceDate]];
    STAssertEqualObjects(a, b, @"Updated at timestamps differ for task '%@' (%@)", task.body, task.key);
    
    a = [NSString stringWithFormat:@"%0.8f", [match.sortDate timeIntervalSinceReferenceDate]];
    b = [NSString stringWithFormat:@"%0.8f", [task.sortDate timeIntervalSinceReferenceDate]];
    STAssertEqualObjects(a, b, @"Sort date timestamps differ for task '%@' (%@)", task.body, task.key);
    
    STAssertEquals(match.isComplete, task.isComplete, @"Is complete is not correct for task '%@' (%@)", task.body, task.key);
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
  NSError *error = nil;
  [self.client loadTasksAndTaskLists:@"{ \
    \"task_lists\": [ \
     { \"name\": \"Tasks\" }, \
     { \"name\": \"Groceries\" } \
    ] \
  }" error:&error];
  
  TaskList *list = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  list.name = @"Another List";
  list = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  list.name = @"Tasks";
   
  [self.syncMaster syncAll:&error];
  
  TaskList *localTasks = [self localListWithKey:@"tasks"];
  STAssertNotNil(localTasks, @"Local tasks should not be nil!");
  STAssertNotNil(localTasks.key, @"Local tasks should now have a key assigned.");
  STAssertEqualObjects(localTasks.name, @"Tasks", @"Local list should be called Tasks");
  
  [self assertListsSynced:3];
  
  list = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  list.name = @"Yet another List";
  
  [self.syncMaster syncAll:&error];
  [self assertListsSynced:4];
  
  DonezoTaskList *remoteList = [client getListWithKey:@"groceries" error:&error];
  [client deleteList:&remoteList error:&error];
  STAssertNil(error, @"Encountered an error! %@", [error description]);
  
  [self.syncMaster syncAll:&error];
  [self assertListsSynced:3];
  
  /*
  // This should be modified to use list.deleted = true or similar
  list = [self localListWithKey:@"tasks"];
  [self.context deleteObject:list];
  STAssertNil(error, @"Encountered an error! %@", [error description]);
  
  [self.syncMaster syncAll:&error];
  [self assertListsSynced:2];
  */
}

// Makes sure we properly handle the case when we have new
// tasks both locally and remotely.
//
// Then, test to make sure we sync existing tasks to get remote
// changes and that local changes are saved remotely.
//
- (void) testNewTasksRemoteAndLocal
{
  NSError *error = nil;
  [self.client loadTasksAndTaskLists:@"{ \
   \"task_lists\": [ \
     { \"name\": \"Tasks\" }, \
     { \"name\": \"Groceries\" } \
   ], \
   \"tasks\": [ \
     { \"body\": \"A remote task in Tasks.\", \"task_list\": \"tasks\", \"project\": \"Some project\", \"complete\": true }, \
     { \"body\": \"A remote task in Groceries.\", \"task_list\": \"groceries\", \"contexts\": [\"home\", \"work\"] }, \
     { \"body\": \"A second remote task in Groceries.\", \"task_list\": \"groceries\", \"project\": null, \"contexts\": null } \
   ] \
  }" error:&error];
  
  TaskList *anotherList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  anotherList.name = @"Another List";
  
  TaskList *tasksList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
  tasksList.name = @"Tasks";
  tasksList.key = @"tasks";
  
  Task *task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
  task.taskList = tasksList;
  task.isComplete = YES;
  task.body = @"A local task in the Tasks list";
  task.contexts = [NSSet setWithArray:[Context findOrCreateContextsWithNames:[NSArray arrayWithObject:@"school"] inContext:self.context]];
  
  task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
  task.taskList = tasksList;
  task.body = @"A local task in the Tasks list that has been deleted remotely!";
  task.key = [NSNumber numberWithInt:400000];
  
  task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
  task.taskList = anotherList;
  task.body = @"A task in the Another List list.";
  task.contexts = [NSSet setWithArray:[Context findOrCreateContextsWithNames:[NSArray arrayWithObject:@"school"] inContext:self.context]];

  task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
  task.taskList = anotherList;
  task.isComplete = YES;
  task.body = @"A second task in the Another List list.";
  
  [self.syncMaster syncAll:&error];
 
  [self assertListsSynced:3];
  [self assertTasksSynced:2 forListWithKey:@"groceries"];
  [self assertTasksSynced:2 forListWithKey:@"tasks"];
  [self assertTasksSynced:2 forListWithKey:@"another-list"];
}

- (void) testUpdatedTask
{
  NSError *error = nil;
  [self.client loadTasksAndTaskLists:@"{ \
   \"task_lists\": [ \
   { \"name\": \"Tasks\" } \
   ], \
   \"tasks\": [ \
   { \"body\": \"A remote task in Tasks.\", \"task_list\": \"tasks\", \"project\": \"Some project\" } \
   ] \
   }" error:&error];
  
  [self.syncMaster syncAll:&error];
  
  [self assertListsSynced:1];
  [self assertTasksSynced:1 forListWithKey:@"tasks"];

  NSArray *tasks = [self.client getTasksForListWithKey:@"tasks" error:&error];
  DonezoTask *t = [tasks objectAtIndex:0];
  
  NSString *newBody = [t.body stringByAppendingString:@" (this has been changed!)"];
  t.body = newBody;
  [self.client saveTask:&t taskList:nil error:&error];
    
  [self.syncMaster syncAll:&error];
  
  [self assertListsSynced:1];
  // This will compare the tasks to make sure they are equal.
  [self assertTasksSynced:1 forListWithKey:@"tasks"];

  TaskList *localTaskList = [self localListWithKey:@"tasks"];
  NSArray *localTasks = [[localTaskList tasks] allObjects];
  Task *task = [localTasks objectAtIndex:0];
  
  STAssertEqualObjects(newBody, task.body, @"New body should be equal to the modified version we saved earlier.");
  
  for (int i; i < 3; i++)
  {
    NSLog(@"Making a local change (run %d)", i);
    
    newBody = [task.body stringByAppendingString:@" ... altered!"];
    task.body = newBody;
    task.sortDate = [NSDate date];
    NSDate *oldUpdatedAt = [task.updatedAt copy];
    [task hasBeenUpdated];
    
    NSTimeInterval interval = [task.updatedAt timeIntervalSinceDate:oldUpdatedAt];
    STAssertTrue(interval > 0, @"New updated at should be larger than old updated at, but was: %0.4f", interval);
    oldUpdatedAt = [task.updatedAt copy];
    
    [self.syncMaster syncAll:&error];
    STAssertNil(error, @"Error should be nil.");
    
    // reload task object
    task = (Task*)[self.context objectWithID:[task objectID]];
    STAssertEqualObjects(newBody, task.body, @"New body should be equal to the modified version we saved earlier.");
    interval = [task.updatedAt timeIntervalSinceDate:oldUpdatedAt];
    STAssertTrue(interval > 0, @"New updated at should be larger than old updated at, but was: %0.4f", interval);
    
    
    [self assertListsSynced:1];
    // This will compare the tasks to make sure they are equal.
    [self assertTasksSynced:1 forListWithKey:@"tasks"];    
  }
}

- (void) testDeletedSyncedTaskLocally
{
  NSError *error = nil;
  [self.client loadTasksAndTaskLists:@"{ \
   \"task_lists\": [ \
   { \"name\": \"Tasks\" } \
   ], \
   \"tasks\": [ \
   { \"body\": \"A remote task!\", \"task_list\": \"tasks\", \"project\": \"Some project\" }, \
   { \"body\": \"A second remote task!\", \"task_list\": \"tasks\" } \
   ] \
   }" error:&error];
  
  [self.syncMaster syncAll:&error];
  STAssertNil(error, @"Error should be nil.");
  
  [self assertListsSynced:1];
  [self assertTasksSynced:2 forListWithKey:@"tasks"];
  
  TaskList *localTaskList = [self localListWithKey:@"tasks"];
  NSArray *localTasks = [[localTaskList tasks] allObjects];
  Task *task = [localTasks objectAtIndex:0];

  // now delete the task
  task.isDeleted = YES;
  NSString *deletedBody = [task.body copy];

  [self.syncMaster syncAll:&error];
  STAssertNil(error, @"Error should be nil.");
  
  [self assertListsSynced:1];
  [self assertTasksSynced:1 forListWithKey:@"tasks"];
  
  localTaskList = [self localListWithKey:@"tasks"];
  localTasks = [[localTaskList tasks] allObjects];
  task = [localTasks objectAtIndex:0];
  
  STAssertTrue(![task.body isEqualToString:deletedBody], @"Apparently the wrong task was deleted!");
}

- (void) testArchivedSyncedTaskLocally
{
  NSError *error = nil;
  [self.client loadTasksAndTaskLists:@"{ \
   \"task_lists\": [ \
   { \"name\": \"Tasks\" } \
   ], \
   \"tasks\": [ \
   { \"body\": \"A remote task!\", \"task_list\": \"tasks\", \"project\": \"Some project\" }, \
   { \"body\": \"A second remote task!\", \"task_list\": \"tasks\" } \
   ] \
   }" error:&error];
  
  [self.syncMaster syncAll:&error];
  STAssertNil(error, @"Error should be nil, but was %@", [error description]);
  
  [self assertListsSynced:1];
  [self assertTasksSynced:2 forListWithKey:@"tasks"];
  
  TaskList *localTaskList = [self localListWithKey:@"tasks"];
  NSArray *localTasks = [[localTaskList tasks] allObjects];
  Task *task = [localTasks objectAtIndex:0];
  
  NSString *archivedBody = [task.body copy];
  // now archive the task
  task.isComplete = YES;
  task.isArchived = YES;
  [task hasBeenUpdated];
  
  [self.syncMaster syncAll:&error];
  STAssertNil(error, @"Error should be nil.");
  
  [self assertListsSynced:1];
  [self assertTasksSynced:1 forListWithKey:@"tasks"];
  
  localTaskList = [self localListWithKey:@"tasks"];
  localTasks = [self tasksForList:localTaskList];
  task = [localTasks objectAtIndex:0];
  
  STAssertTrue(![task.body isEqualToString:archivedBody], @"Apparently the wrong task was archived!");
  
  // Get the tasks we consider during a sync for this list
  NSDictionary *substitutions = [NSDictionary
                                 dictionaryWithObject:localTaskList
                                 forKey:@"taskList"];
  NSFetchRequest *fetchRequest = [[[self.context persistentStoreCoordinator] managedObjectModel]
                                  fetchRequestFromTemplateWithName:@"tasksForListToSync"
                                  substitutionVariables:substitutions];
  localTasks = [self.context executeFetchRequest:fetchRequest error:nil];
  
  STAssertEquals((NSUInteger)1, [localTasks count], @"Tasks to sync should only have a single task.");

  // Get ALL TASKS for this list
  localTasks = [[localTaskList tasks] allObjects];
  
  STAssertEquals((NSUInteger)2, [localTasks count], @"All tasks should still have both tasks.");
  
  Task* taskA = ((Task*)[localTasks objectAtIndex:0]);
  Task* taskB = ((Task*)[localTasks objectAtIndex:1]);
  STAssertTrue(taskA.isArchived || taskB.isArchived, @"One of the tasks should be archived.");
  STAssertTrue(!(taskA.isArchived && taskB.isArchived), @"One of the tasks should not be archived.");
}



// Tests to make sure we properly handle the case where
// a task was updated remotely and locally, so we choose the
// latest one.
//
- (void) testUpdatedTasksWithConflict
{
}


@end
