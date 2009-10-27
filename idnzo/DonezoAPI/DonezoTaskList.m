//
//  DonezoTaskList.m
//  DNZO
//
//  Created by Taylor Hughes on 7/28/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "DonezoTaskList.h"

@implementation DonezoTaskList

@synthesize key;
@synthesize name;
@synthesize tasksCount;

+ (DonezoTaskList*) taskListFromDictionary:(NSDictionary*)dict
{
  DonezoTaskList *taskList = [[[DonezoTaskList alloc] init] autorelease];
  
  taskList.key        = [dict valueForKey:@"key"];
  taskList.name       = [dict valueForKey:@"name"];
  taskList.tasksCount = [dict valueForKey:@"tasks_count"];
  
  return taskList;
}

- (void) dealloc
{
  [key release];
  [name release];
  [tasksCount release];
  [super dealloc];
}

@end
