//
//  MockDonezoAPIClient.m
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "MockDonezoAPIClient.h"

@implementation MockDonezoAPIClient

@synthesize taskLists;
@synthesize tasks;

- (void) dealloc
{
  [taskLists release];
  [tasks release];
  [super dealloc];
}

- (void) loadTasksAndTaskLists:(NSString*)jsonData
{
  // parse json into dictionary
  SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
  NSDictionary *dict = (NSDictionary*) [parser objectWithString:jsonData];
  
  self.taskLists = [NSMutableArray array];
  self.tasks = [NSMutableDictionary dictionary];
  
  // extract "task_lists" and add them to self.taskLists
  if ([dict objectForKey:@"task_lists"] != nil)
  {
    for (NSDictionary *listDict in (NSArray*)[dict objectForKey:@"task_lists"])
    {
      DonezoTaskList *list = [DonezoTaskList taskListFromDictionary:listDict];
      [self.taskLists addObject:list];
      [self.tasks setValue:[NSMutableArray array] forKey:list.key];
    }    
  }
  
  // extract "tasks" and add them to self.tasks
  // extract "task_lists" and add them to self.taskLists
  if ([dict objectForKey:@"tasks"] != nil)
  {
    for (NSDictionary *taskDict in (NSArray*)[dict objectForKey:@"tasks"])
    {
      DonezoTask *task = [DonezoTask taskFromDictionary:taskDict];
      NSMutableArray *arr = (NSMutableArray*)[self.tasks objectForKey:task.taskListKey];
      [arr addObject:task];
    }    
  }
}

- (void) login
{
  NSAssert(NO, @"Attempted call to mock [MockDonezoAPIClient login]. This should not happen.");
}

- (NSArray*) getLists:(NSError**)error
{
  return self.taskLists;
}
- (NSArray*) getTasksForListWithKey:(NSString*)key error:(NSError**)error
{
  NSArray *ret = (NSArray*)[self.tasks objectForKey:key];
  if (ret) {
    return ret;
  }
  return [NSArray array];
}

- (void) saveTask:(DonezoTask**)task taskList:(DonezoTaskList*)list error:(NSError**)error
{
  NSMutableArray *collection = [self.tasks objectForKey:list.key];

  if ((*task).key != nil && ![(*task).key isMemberOfClass:[NSNull class]])
  {
    DonezoTask *match = nil;
    for (DonezoTask *otherTask in collection)
    {
      if ([otherTask.key isEqual:(*task).key])
      {
        match = otherTask;
        break;
      }
    }
    if (match)
    {
      [collection removeObject:match];
      [collection addObject:(*task)];
    }
  }
  else
  {
    (*task).key = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
    [collection addObject:(*task)];
  }
}

- (void) deleteTask:(DonezoTask**)task error:(NSError**)error
{
  DonezoTask *match = nil;
  NSMutableArray *collection = [self.tasks objectForKey:(*task).taskListKey];
  for (DonezoTask *otherTask in collection)
  {
    if ([otherTask.key isEqual:(*task).key])
    {
      match = otherTask;
      break;
    }
  }
  if (match)
  {
    [collection removeObject:match];
  }  
}

- (void) saveList:(DonezoTaskList**)list error:(NSError**)error
{
  if (!(*list).key)
  {
    (*list).key = [(*list).key lowercaseString];
    [self.taskLists addObject:(*list)];    
  }
}

- (void) deleteList:(DonezoTaskList**)list error:(NSError**)error
{
  DonezoTaskList *match = nil;
  for (DonezoTaskList *otherList in self.taskLists)
  {
    if ([otherList.key isEqual:(*list).key]) {
      match = otherList;
      break;
    }
  }
  if (match)
  {
    [self.taskLists removeObject:match];
  }
}

@end
