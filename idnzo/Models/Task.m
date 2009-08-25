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

@dynamic key;
@dynamic body;
@dynamic dueDate;
@dynamic updatedAt;
@dynamic complete;
@dynamic archived;
@dynamic taskList;
@dynamic contexts;
@dynamic project;

@synthesize updatedSetManually;

- (void) dealloc
{
  [super dealloc];
}

- (void) willSave
{
  if ((!self.updatedAt || [self.updatedAt timeIntervalSinceNow] < -0.01) && !self.updatedSetManually)
  {
    self.updatedAt = [NSDate date];
    NSLog(@"Set updatedAt to %@", self.updatedAt);
  }
  self.updatedSetManually = NO;
}

- (void) setUpdatedAtManually:(NSDate*)newUpdatedAt
{
  self.updatedAt = newUpdatedAt;
  self.updatedSetManually = YES;
}

- (NSString *)dueString
{
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
  NSString *dueStr = [dateFormatter stringFromDate:self.dueDate];
  NSLog(@">>>>>>>>>> Due string: %@", dueStr);
  return dueStr;
}

- (NSString *)contextsString
{
  if (!self.contexts || [self.contexts count] == 0)
  {
    return nil;
  }
  return [@"@" stringByAppendingString:[[self contextNames] componentsJoinedByString:@" @"]];
}

- (NSArray*)contextNames
{
  NSMutableArray *contextNames = [NSMutableArray arrayWithCapacity:[self.contexts count]];
  for (Context *context in self.contexts)
  {
    [contextNames addObject:context.name];
  }
  return contextNames;
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
