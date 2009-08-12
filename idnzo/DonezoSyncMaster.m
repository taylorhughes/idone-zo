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
  
  NSLog(@"Saved local lists: %@", [savedLocalLists description]);
  NSLog(@"New local lists: %@", [newLocalLists description]);
    
  NSMutableArray *newRemoteLists = [NSMutableArray arrayWithArray:[self.client getLists:error]];
  if (*error != nil) { return nil; }
  
  NSLog(@"New remote lists: %@", [newRemoteLists description]);
  
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
    NSLog(@"Deleting local list: %@", listToDelete.name);
    
    for (Task *taskToDelete in [listToDelete tasks])
    {
      [self.context deleteObject:taskToDelete];
    }
    [self.context deleteObject:listToDelete];
  }
  for (DonezoTaskList *listToAddLocally in newRemoteLists)
  {
    NSLog(@"Adding remote list locally: %@", listToAddLocally.name);
    TaskList *newList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
    newList.name = listToAddLocally.name;
    newList.key = listToAddLocally.key;
  }
  for (TaskList *listToAdd in localListsToAddRemotely)
  {
    NSLog(@"Adding local list remotely: %@", listToAdd.name);
    
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
  
  NSLog(@"Saved local tasks: %@", [savedLocalTasks description]);
  NSLog(@"New local tasks: %@", [newLocalTasks description]);
  
  NSMutableArray *newRemoteTasks = [NSMutableArray arrayWithArray:[self.client getTasksForListWithKey:taskList.key error:error]];
  if (*error != nil) { return; }
  
  NSMutableArray *localTasksToDelete = [NSMutableArray arrayWithCapacity:[savedLocalTasks count]];
  
  //
  // For the lists we have saved before, try to find the matching remote list.
  // ** If it's not there, it's been deleted. **
  //
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
    }
    else
    {
      // this list is no longer present remotely. delete it here.
      [localTasksToDelete addObject:localTask];
    }
  }
  
  //
  // Now, add and remove existing lists as detailed by the various collections.
  //
  for (Task *taskToDelete in localTasksToDelete)
  {
    NSLog(@"Deleting local task: %@", taskToDelete.key);
    [self.context deleteObject:taskToDelete];
  }
  for (DonezoTask *taskToAddLocally in newRemoteTasks)
  {
    NSLog(@"Adding remote task locally: %@", taskToAddLocally.key);
    Task *newTask = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
    newTask.key = taskToAddLocally.key;
    newTask.body = taskToAddLocally.body;
    newTask.taskList = taskList;
    NSLog(@"Added new task (%@) with key (%@)", newTask.body, newTask.key);
//    newTask.project = [Project findProjectWithName:taskToAddLocally.project inContext:self.context];
//    newTask.contexts = 
  }
  for (Task *taskToAdd in newLocalTasks)
  {
    NSLog(@"Adding local task remotely: %@", taskToAdd.key);
    
    DonezoTask *task = [[[DonezoTask alloc] init] autorelease];
    task.body = taskToAdd.body;
    task.project = taskToAdd.project.name;
    task.contexts = [taskToAdd contextNames];
    
    DonezoTaskList *remoteList = [[[DonezoTaskList alloc] init] autorelease];
    remoteList.key = taskList.key;
    remoteList.name = taskList.name;
    
    [client saveTask:&task taskList:remoteList error:error];
    if (*error)
    {
      return;
    }
    taskToAdd.key = task.key;
  }
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
