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

- (void) setTasksAndTaskLists:(NSString*)jsonData
{
  // parse json into dictionary
  // extract "task_lists" and add them to self.taskLists
  // extract "tasks" and add them to self.tasks
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
  return (NSArray*)[self.tasks objectForKey:key];
}

- (void) saveTask:(DonezoTask**)task taskList:(DonezoTaskList*)list error:(NSError**)error
{
}
- (void) deleteTask:(DonezoTask**)task error:(NSError**)error
{
}

- (void) saveList:(DonezoTaskList**)list error:(NSError**)error
{
}
- (void) deleteList:(DonezoTaskList**)list error:(NSError**)error
{
}



@end
