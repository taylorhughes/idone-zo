//
//  SyncMaster.m
//  DNZO
//
//  Created by Taylor Hughes on 8/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DonezoSyncMaster.h"

@interface DonezoSyncMaster (Private)

- (NSArray*) getCurrentTasks:(NSError**)error;

- (NSArray*) syncLists:(NSError**)error;
- (void) syncList:(TaskList*)taskList error:(NSError**)error;

- (NSArray*) getLocalTasksForTaskList:(TaskList*)taskList error:(NSError**)error;
- (NSArray*) getLocalTaskLists:(NSError**)error;

- (void) copyRemoteTask:(DonezoTask*)remoteTask toLocalTask:(Task*)localTask;
- (void) copyLocalTask:(Task*)localTask toRemoteTask:(DonezoTask*)remoteTask;

@end

@implementation DonezoSyncMaster

@synthesize client;
@synthesize context;

- (id) initWithDonezoClient:(DonezoAPIClient*)donezoClient andContext:(NSManagedObjectContext*)managedObjectContext
{
  self = [super init];
  if (self != nil)
  {
    self.client = donezoClient;
    self.context = managedObjectContext;
  }
  return self;
}

- (void) performSync:(NSError**)error
{
  NSLog(@"Syncing lists..");
  NSArray *lists = [self syncLists:error];
  if (*error != nil) return;
  
  for (TaskList *list in lists)
  {
    NSLog(@"Syncing tasks for list %@...", list.name);
    [self syncList:list error:error];
    if (*error != nil) { return; }
  }
  
  [self.context save:error];
}

- (NSArray*) syncLists:(NSError**)error
{
  NSArray *localLists = [self getLocalTaskLists:error];
  if (*error != nil) { return nil; }
    
  NSMutableArray *savedLocalLists = [NSMutableArray arrayWithCapacity:[localLists count]];
  NSMutableArray *newLocalLists = [NSMutableArray arrayWithCapacity:[localLists count]];
  
  // Separate the existing local lists into ones that 
  // we have synced before and ones we have not.
  for (TaskList *localList in localLists)
  {
    if (localList.key != nil)
    {
      [savedLocalLists addObject:localList];
    }
    else
    {
      [newLocalLists addObject:localList];
    }
  }
      
  NSMutableArray *newRemoteLists = [NSMutableArray arrayWithArray:[self.client getLists:error]];
  if (*error != nil) { return nil; }
  
  NSMutableArray *localListsToDelete = [NSMutableArray arrayWithCapacity:[savedLocalLists count]];
  NSMutableArray *localListsToAddRemotely = [NSMutableArray arrayWithCapacity:[newLocalLists count]];
  
  //
  // For the lists we have saved before, try to find the matching remote list.
  // ** If it's not there, it's been deleted. **
  //
  for (TaskList *localList in savedLocalLists)
  {
    DonezoTaskList *existingRemoteList = nil;
    for (DonezoTaskList *remoteList in newRemoteLists)
    {
      if ([localList.key isEqualToString:remoteList.key])
      {
        existingRemoteList = remoteList;
        break;
      }
    }
    
    if (existingRemoteList)
    {
      //if (localList.deleted)
      //{
      //  // delete remote list
      //}
      //else
      //{

      // remove object from collection of new lists; we know about it already
      [newRemoteLists removeObject:existingRemoteList];
      
      //}
    }
    else
    {
      // this list is no longer present remotely. delete it here.
      [localListsToDelete addObject:localList];
    }
  }
  
  //
  // For new local lists, look through the remaining remote lists 
  // and attempt to reconcile names. If there is a new list here
  // with the same name as a list remotely that does not already 
  // exist here (that would have been taken care of above), then
  // use that one.
  //
  for (TaskList *localList in newLocalLists)
  {
    DonezoTaskList *existingRemoteList = nil;
    for (DonezoTaskList *remoteList in newRemoteLists)
    {
      if ([localList.name isEqualToString:remoteList.name])
      {
        existingRemoteList = remoteList;
        break;
      }
    }
    
    if (existingRemoteList)
    {
      // remove object from collection of new lists; we know about it already
      [newRemoteLists removeObject:existingRemoteList];
      localList.key = existingRemoteList.key;
      NSLog(@"Reconciled remote list and local list %@!", existingRemoteList.name);
    }
    else
    {
      [localListsToAddRemotely addObject:localList];
    }
  }
  
  //
  // Now, add and remove existing lists as detailed by the various collections.
  //
  for (TaskList *listToDelete in localListsToDelete)
  {
    for (Task *taskToDelete in [listToDelete tasks])
    {
      [self.context deleteObject:taskToDelete];
    }
    [self.context deleteObject:listToDelete];
  }
  for (DonezoTaskList *listToAddLocally in newRemoteLists)
  {
    TaskList *newList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
    newList.name = listToAddLocally.name;
    newList.key = listToAddLocally.key;
  }
  for (TaskList *listToAdd in localListsToAddRemotely)
  {    
    DonezoTaskList *list = [[[DonezoTaskList alloc] init] autorelease];
    list.name = listToAdd.name;
    
    [client saveList:&list error:error];
    if (*error)
    {
      return nil;
    }
    listToAdd.key = list.key;
  }
  
  // final collection of TaskList* objects -- todo: replace this with a premade collection or something
  return [self getLocalTaskLists:error]; 
}

- (void) syncList:(TaskList*)taskList error:(NSError**)error
{
  NSArray *localTasks = [self getLocalTasksForTaskList:taskList error:error];
  if (*error != nil) { return; }
  
  NSMutableArray *savedLocalTasks = [NSMutableArray arrayWithCapacity:[localTasks count]];
  NSMutableArray *newLocalTasks = [NSMutableArray arrayWithCapacity:[localTasks count]];
  
  // Separate the existing local lists into ones that 
  // we have synced before and ones we have not.
  for (Task *localTask in localTasks)
  {
    if (localTask.key != nil)
    {
      [savedLocalTasks addObject:localTask];
    }
    else
    {
      [newLocalTasks addObject:localTask];
    }
  }
  
  NSMutableArray *newRemoteTasks = [NSMutableArray arrayWithArray:[self.client getTasksForListWithKey:taskList.key error:error]];
  if (*error != nil) { return; }
  
  NSMutableArray *tasksToSync = [NSMutableArray arrayWithCapacity:[savedLocalTasks count]];
  NSMutableArray *localTasksToDelete = [NSMutableArray arrayWithCapacity:[savedLocalTasks count]];
  
  for (Task *localTask in savedLocalTasks)
  {
    DonezoTask *existingRemoteTask = nil;
    for (DonezoTask *remoteTask in newRemoteTasks)
    {
      if ([localTask.key isEqual:remoteTask.key])
      {
        existingRemoteTask = remoteTask;
        break;
      }
    }
    
    if (existingRemoteTask)
    {
      [newRemoteTasks removeObject:existingRemoteTask];
      [tasksToSync addObject:[NSArray arrayWithObjects:existingRemoteTask, localTask, nil]];
    }
    else
    {
      // this list is no longer present remotely. delete it here.
      [localTasksToDelete addObject:localTask];
    }
  }
  
  
  NSLog(@"=== SYNC: %@ ===", taskList.key);
  NSLog(@"%d local tasks to delete..", [localTasksToDelete count]);
  NSLog(@"%d new remote tasks to add locally...", [newRemoteTasks count]);
  NSLog(@"%d new local tasks to add remotely...", [newLocalTasks count]);
  NSLog(@"%d existing tasks to sync.", [tasksToSync count]);
    
  //
  // Now, add and remove existing lists as detailed by the various collections.
  //
  for (Task *localTask in localTasksToDelete)
  {
    //NSLog(@"Deleting local task: %@", taskToDelete.key);
    [self.context deleteObject:localTask];
  }
  for (DonezoTask *remoteTask in newRemoteTasks)
  {
    //NSLog(@"Adding remote task locally: %@", taskToAddLocally.key);
    Task *localTask = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
    localTask.taskList = taskList;
    [self copyRemoteTask:remoteTask toLocalTask:localTask];
  }
  for (Task *localTask in newLocalTasks)
  {
    //NSLog(@"Adding local task remotely: %@", taskToAdd.key);
    DonezoTask *remoteTask = [[[DonezoTask alloc] init] autorelease];

    [self copyLocalTask:localTask toRemoteTask:remoteTask];
    
    DonezoTaskList *remoteList = [[[DonezoTaskList alloc] init] autorelease];
    remoteList.key = taskList.key;
    remoteList.name = taskList.name;
    
    [client saveTask:&remoteTask taskList:remoteList error:error];
    if (*error)
    {
      return;
    }
    localTask.key = remoteTask.key;
    NSLog(@"[Task %@] Setting updatedAt to %@", localTask.key, [NSString stringWithFormat:@"%0.8f", [remoteTask.updatedAt timeIntervalSinceReferenceDate]]);
    [localTask hasBeenUpdated:remoteTask.updatedAt];
  }
  for (NSArray *remoteLocalTasks in tasksToSync)
  {
    DonezoTask *remoteTask = [remoteLocalTasks objectAtIndex:0];
    Task *localTask = [remoteLocalTasks objectAtIndex:1];
    
    NSTimeInterval remoteUpdatedInterval = [remoteTask.updatedAt timeIntervalSinceDate:localTask.updatedAt];
    if (remoteUpdatedInterval > 0)
    {
      NSLog(@"Remote task (%@ - %@) is newer than local task (%@ - %@)...", remoteTask.body, remoteTask.updatedAt, localTask.body, localTask.updatedAt);
      [self copyRemoteTask:remoteTask toLocalTask:localTask];
    }
    else if (remoteUpdatedInterval < 0)
    {
      NSLog(@"Local task (%@ - %@) is newer than remote task (%@ - %@)...", localTask.body, localTask.updatedAt, remoteTask.body, remoteTask.updatedAt);
      [self copyLocalTask:localTask toRemoteTask:remoteTask];
      [self.client saveTask:&remoteTask taskList:nil error:error];
      [localTask hasBeenUpdated:remoteTask.updatedAt];
    }
  }
}

- (void) copyRemoteTask:(DonezoTask*)remoteTask toLocalTask:(Task*)localTask
{
  localTask.key = remoteTask.key;
  localTask.body = remoteTask.body;
  localTask.dueDate = remoteTask.dueDate;
  [localTask hasBeenUpdated:remoteTask.updatedAt];
  
  localTask.project = [Project findOrCreateProjectWithName:remoteTask.project inContext:self.context];
  localTask.contexts = [NSSet setWithArray:[Context findOrCreateContextsWithNames:remoteTask.contexts inContext:self.context]];
}

- (void) copyLocalTask:(Task*)localTask toRemoteTask:(DonezoTask*)remoteTask
{
  remoteTask.body     = localTask.body;
  remoteTask.project  = localTask.project.name;
  remoteTask.contexts = [localTask contextNames];
  remoteTask.dueDate = localTask.dueDate;
}

- (NSArray*) getLocalTasksForTaskList:(TaskList*)taskList error:(NSError**)error
{
  return [[taskList tasks] allObjects];
}

- (NSArray*) getLocalTaskLists:(NSError**)error
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.context];
  request.entity = entity;
  
  return [self.context executeFetchRequest:request error:error];
}

@end
