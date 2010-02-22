//
//  SyncMaster.m
//  DNZO
//
//  Created by Taylor Hughes on 8/4/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "DonezoSyncMaster.h"

@interface DonezoSyncMaster (Private)

- (NSArray*) getCurrentTasks:(NSError**)error;

- (NSArray*) getLocalTasksForTaskList:(TaskList*)taskList error:(NSError**)error;
- (NSArray*) getLocalTaskLists:(NSError**)error;

- (void) copyRemoteTask:(DonezoTask*)remoteTask toLocalTask:(Task*)localTask;
- (void) copyLocalTask:(Task*)localTask toRemoteTask:(DonezoTask*)remoteTask;

- (BOOL) errorOrCanceled:(NSError**)error;

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
    canceled = NO;
  }
  return self;
}

- (void) cancel
{
  canceled = YES;
}
- (BOOL) isCanceled
{
  return canceled;
}
- (BOOL) errorOrCanceled:(NSError**)error
{
  return [self isCanceled] || *error != nil;
}

- (void) dealloc
{
  [client release];
  [context release];
  [super dealloc];
}

- (void) syncAll:(NSError**)error
{
  NSLog(@"Syncing lists..");
  NSArray *lists = [self syncLists:error];
  if ([self errorOrCanceled:error]) return;
  
  for (TaskList *list in lists)
  {
    NSLog(@"Syncing tasks for list %@...", list.name);
    [self syncList:list error:error];
    if ([self errorOrCanceled:error]) { return; }
  }
}

- (NSArray*) syncLists:(NSError**)error
{
  NSArray *localLists = [self getLocalTaskLists:error];
  if ([self errorOrCanceled:error]) { return nil; }
    
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
  
  if ([self errorOrCanceled:error]) { return nil; }
  NSMutableArray *newRemoteLists = [NSMutableArray arrayWithArray:[self.client getLists:error]];
  if ([self errorOrCanceled:error]) { return nil; }
  
  NSMutableArray *localListsToDelete = [NSMutableArray arrayWithCapacity:[savedLocalLists count]];
  NSMutableArray *localListsToAddRemotely = [NSMutableArray arrayWithCapacity:[newLocalLists count]];
  NSMutableArray *localRemoteListsToDelete = [NSMutableArray arrayWithCapacity:[newRemoteLists count]];
  
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
      [newRemoteLists removeObject:existingRemoteList];
      
      if (localList.isDeleted)
      {
        [localRemoteListsToDelete addObject:[NSArray arrayWithObjects:localList, existingRemoteList, nil]];
      }
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
  
  if ([self errorOrCanceled:error]) { return nil; }
  
  NSLog(@"=== Syncing lists ===");
  NSLog(@"New local lists:        %d", [localListsToAddRemotely count]);
  NSLog(@"Local lists to delete:  %d", [localListsToDelete count]);
  NSLog(@"New remote lists:       %d", [newRemoteLists count]);
  
  //
  // Remove existing, deleted lists
  //
  for (TaskList *listToDelete in localListsToDelete)
  {
    for (Task *taskToDelete in [listToDelete tasks])
    {
      [self.context deleteObject:taskToDelete];
    }
    [self.context deleteObject:listToDelete];
  }
  if ([self.context hasChanges])
  {
    [self.context save:error];
  }
  if ([self errorOrCanceled:error]) { return nil; }
  
  //
  // Add new lists
  //
  for (DonezoTaskList *listToAddLocally in newRemoteLists)
  {
    TaskList *newList = (TaskList*)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:self.context];
    newList.name = listToAddLocally.name;
    newList.key = listToAddLocally.key;
  }
  if ([self.context hasChanges])
  {
    [self.context save:error];
  }
  if ([self errorOrCanceled:error]) { return nil; }
  
  //
  // Add new local lists remotely
  //
  for (TaskList *listToAdd in localListsToAddRemotely)
  {    
    DonezoTaskList *list = [[[DonezoTaskList alloc] init] autorelease];
    list.name = listToAdd.name;
    
    [client saveList:&list error:error];
    // In this case, do not check canceled -- would leave data inconsistent
    if (*error) { return nil; }
    listToAdd.key = list.key;
    
    [self.context save:error];
    // Now we can check canceled
    if ([self errorOrCanceled:error]) { return nil; }
  }
  
  //
  // NOTE: This has to happen AFTER new lists are added, in case we are removing 
  // all remote lists and replacing them. In that case, the list count must not
  // reach ZERO or the donezo API will return a 400.
  //
  for (NSArray *localRemotePair in localRemoteListsToDelete)
  {
    TaskList *localList = [localRemotePair objectAtIndex:0];
    DonezoTaskList *remoteList = [localRemotePair objectAtIndex:1];
    
    [self.client deleteList:&remoteList error:error];
    // Do not check canceled in this case
    if (*error) { return nil; }
    [self.context deleteObject:localList];
    
    [self.context save:error];
    // Now we can check canceled
    if ([self errorOrCanceled:error]) { return nil; }
  }
  
  // final collection of TaskList* objects -- todo: replace this with a premade collection or something
  return [self getLocalTaskLists:error]; 
}

- (void) syncList:(TaskList*)taskList error:(NSError**)error
{
  NSArray *localTasks = [self getLocalTasksForTaskList:taskList error:error];
  if ([self errorOrCanceled:error]) { return; }
  
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
  
  if ([self errorOrCanceled:error]) { return; }
  NSMutableArray *newRemoteTasks = [NSMutableArray arrayWithArray:[self.client getTasksForListWithKey:taskList.key error:error]];
  if ([self errorOrCanceled:error]) { return; }
  
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
      [localTasksToDelete addObject:localTask];
    }
  }
  
  if ([self errorOrCanceled:error]) { return; }
  
  NSLog(@"=== SYNC: %@ ===", taskList.key);
  NSLog(@"%d local tasks to delete..", [localTasksToDelete count]);
  NSLog(@"%d new remote tasks to add locally...", [newRemoteTasks count]);
  NSLog(@"%d new local tasks to add remotely...", [newLocalTasks count]);
  NSLog(@"%d existing tasks to sync.", [tasksToSync count]);
    
  //
  // Delete tasks that have been deleted remotely
  //
  for (Task *localTask in localTasksToDelete)
  {
    [self.context deleteObject:localTask];
  }
  if ([self.context hasChanges])
  {
    [self.context save:error];
  }
  if ([self errorOrCanceled:error]) { return; }
  
  //
  // Add tasks that were added remotely
  //
  for (DonezoTask *remoteTask in newRemoteTasks)
  {
    Task *localTask = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
    localTask.taskList = taskList;
    [self copyRemoteTask:remoteTask toLocalTask:localTask];
  }
  if ([self.context hasChanges])
  {
    [self.context save:error];
  }
  if ([self errorOrCanceled:error]) { return; }
  
  for (Task *localTask in newLocalTasks)
  {
    //NSLog(@"Adding local task remotely: %@", taskToAdd.key);
    DonezoTask *remoteTask = [[[DonezoTask alloc] init] autorelease];

    [self copyLocalTask:localTask toRemoteTask:remoteTask];
    
    DonezoTaskList *remoteList = [[[DonezoTaskList alloc] init] autorelease];
    remoteList.key = taskList.key;
    remoteList.name = taskList.name;
    
    [client saveTask:&remoteTask taskList:remoteList error:error];
    // Don't check canceled here; would leave data inconsistent
    if (*error) { return; }
    localTask.key = remoteTask.key;
    [localTask hasBeenUpdated:remoteTask.updatedAt];
    
    [self.context save:error];
    if ([self errorOrCanceled:error]) { return; } 
  }
  for (NSArray *remoteLocalTasks in tasksToSync)
  {
    DonezoTask *remoteTask = [remoteLocalTasks objectAtIndex:0];
    Task *localTask = [remoteLocalTasks objectAtIndex:1];

    if (localTask.isDeleted)
    {
      [self.client deleteTask:&remoteTask error:error];
      // Do not check canceled in this case
      if (*error) { return; }
      [self.context deleteObject:localTask];
    }
    else
    {
      NSTimeInterval remoteUpdatedInterval = [remoteTask.updatedAt timeIntervalSinceDate:localTask.updatedAt];
      if (remoteUpdatedInterval < 0 || localTask.isArchived)
      {
        // You might have archived the task while the task is being saved,
        // which would prevent the task from being synced again by doSync==NO,
        // so only set doSync=NO if the task was archived **before the save request happened**
        BOOL wasArchived = localTask.isArchived;
        
        [self copyLocalTask:localTask toRemoteTask:remoteTask];
        [self.client saveTask:&remoteTask taskList:nil error:error];
        if (*error) { return; }
        
        [localTask hasBeenUpdated:remoteTask.updatedAt];
        
        if (wasArchived)
        {
          // Now that we have sync'd the archival,
          // do not sync this task anymore.
          localTask.doSync = NO;
        }
      }
      else if (remoteUpdatedInterval > 0)
      {
        [self copyRemoteTask:remoteTask toLocalTask:localTask];
      }
    }
    
    if (*error == nil && [self.context hasChanges])
    {
      [self.context save:error];
    }
    
    if ([self errorOrCanceled:error]) { return; }
  }
}

- (void) copyRemoteTask:(DonezoTask*)remoteTask toLocalTask:(Task*)localTask
{
  localTask.isComplete = remoteTask.isComplete;
  localTask.key        = remoteTask.key;
  localTask.body       = remoteTask.body;
  localTask.dueDate    = remoteTask.dueDate;
  localTask.sortDate   = remoteTask.sortDate;
  
  localTask.project    = [Project findOrCreateProjectWithName:remoteTask.project inContext:self.context];
  localTask.contexts   = [NSSet setWithArray:[Context findOrCreateContextsWithNames:remoteTask.contexts inContext:self.context]];
  
  [localTask hasBeenUpdated:remoteTask.updatedAt];
}

- (void) copyLocalTask:(Task*)localTask toRemoteTask:(DonezoTask*)remoteTask
{
  remoteTask.isComplete = localTask.isComplete;
  remoteTask.body       = localTask.body;
  remoteTask.project    = localTask.project.name;
  remoteTask.contexts   = [localTask contextNames];
  remoteTask.dueDate    = localTask.dueDate;
  remoteTask.sortDate   = localTask.sortDate;
  remoteTask.isArchived = localTask.isArchived;
}

- (NSArray*) getLocalTasksForTaskList:(TaskList*)taskList error:(NSError**)error
{
  NSDictionary *substitutions = [NSDictionary
                                 dictionaryWithObject:taskList
                                 forKey:@"taskList"];
  NSFetchRequest *fetchRequest = [[[self.context persistentStoreCoordinator] managedObjectModel]
                                  fetchRequestFromTemplateWithName:@"tasksForListToSync"
                                  substitutionVariables:substitutions];
  return [self.context executeFetchRequest:fetchRequest error:error];
}

- (NSArray*) getLocalTaskLists:(NSError**)error
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.context];
  request.entity = entity;
  
  NSArray *retarr = [self.context executeFetchRequest:request error:error];
  [request release];
  return retarr;
}

@end
