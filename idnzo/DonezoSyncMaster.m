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
  NSArray *lists = [self syncLists:error];
  if (error != nil) return;
  
  for (TaskList *list in lists)
  {
    [self syncList:list error:error];
    if (error != nil) { return; }
  }
  
  [self.context save:error];
}

- (NSArray*) syncLists:(NSError**)error
{
  NSArray *localLists = [self getLocalTaskLists:error];
  if (error != nil) { return nil; }
    
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
  if (error != nil) { return nil; }
  
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
    NSLog(@"Adding list %@!", listToAddLocally.name);
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
    list.key = list.key;
  }
  
  // final collection of TaskList* objects -- todo: replace this with 
  return [self getLocalTaskLists:error]; 
}

- (void) syncList:(TaskList*)taskList error:(NSError**)error
{
  
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
