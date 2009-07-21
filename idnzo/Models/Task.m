// 
//  Task.m
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

#import "TaskList.h"
#import "Project.h"

@implementation Task 

@dynamic body;
@dynamic dueDate;
@dynamic complete;
@dynamic archived;
@dynamic taskList;
@dynamic contexts;
@dynamic project;

- (NSString *)dueString
{
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
  return [dateFormatter stringFromDate:self.dueDate];
}

- (NSString *)contextsString
{
  if (!self.contexts || [self.contexts count] == 0)
  {
    return nil;
  }
  NSMutableArray *contextNames = [[NSMutableArray alloc] init];
  for (Context *context in self.contexts)
  {
    [contextNames addObject:context.name];
  }
  return [@"@" stringByAppendingString:[contextNames componentsJoinedByString:@" @"]];
}

- (BOOL)isComplete
{
  return [self.complete intValue];
}
- (void)setIsComplete:(BOOL)isComplete
{
  self.complete = [NSNumber numberWithInt:isComplete];
}

@end
