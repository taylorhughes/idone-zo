// 
//  TaskList.m
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "TaskList.h"
#import "TaskList_Private.h"

#import "Task.h"

@implementation TaskList 

@dynamic name;
@dynamic key;
@dynamic tasks;

@dynamic deleted;
@dynamic sync;

- (NSFetchRequest*)tasksForListRequest
{
  if (tasksForListRequest == nil)
  {
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *substitutions = [NSDictionary dictionaryWithObject:self
                                                              forKey:@"taskList"];
    tasksForListRequest = [[appDelegate.managedObjectModel fetchRequestFromTemplateWithName:@"tasksForList"
                                                                      substitutionVariables:substitutions] retain];
  }
  return tasksForListRequest;
}

- (NSUInteger) displayTasksCount
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  return [appDelegate.managedObjectContext countForFetchRequest:self.tasksForListRequest error:nil];
}

- (BOOL)isDeleted
{
  return [self.deleted intValue];
}
- (void)setIsDeleted:(BOOL)isDeleted
{
  self.deleted = [NSNumber numberWithInt:isDeleted];
}

- (void) dealloc
{
  [tasksForListRequest release];
  [super dealloc];
}

@end