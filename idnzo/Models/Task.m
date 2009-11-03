// 
//  Task.m
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "Task.h"
#import "Task_Private.h"

#import "TaskList.h"
#import "Project.h"

@implementation Task 

@dynamic archived;
@dynamic body;
@dynamic complete;
@dynamic deleted;
@dynamic sync;
@dynamic contexts;
@dynamic dueDate;
@dynamic key;
@dynamic project;
@dynamic sortDate;
@dynamic taskList;
@dynamic updatedAt;

NSDateFormatter *dueDateFormatter;

+ (NSDateFormatter*) dueDateFormatter
{
  if (!dueDateFormatter)
  {
    dueDateFormatter = [[[NSDateFormatter alloc] init] retain];
    [dueDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dueDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dueDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  }
  return dueDateFormatter;
}

- (void) dealloc
{
  [super dealloc];
}

- (void) awakeFromInsert
{
  [super awakeFromInsert];
  // Always set these to be now in case
  [self hasBeenUpdated];
  self.sortDate =  [NSDate date];
}

- (void) hasBeenUpdated
{
  NSDate *newUpdatedAt = [NSDate date];
  if ([newUpdatedAt timeIntervalSinceDate:self.updatedAt] <= 0)
  {
    // This happens when UTC is not synced between remote server and phone.
    // NSLog(@"New updated at was not newer than existing updatedAt; incrementing instead.");
    NSTimeInterval interval = [self.updatedAt timeIntervalSinceReferenceDate] + 0.0001;
    newUpdatedAt = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
  }
  [self hasBeenUpdated:newUpdatedAt];
}
- (void) hasBeenUpdated:(NSDate*)newUpdatedAt
{
  self.updatedAt = newUpdatedAt;
}

- (NSString *)dueString
{
  NSString *dueStr = [[Task dueDateFormatter] stringFromDate:self.dueDate];
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
  [contextNames sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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

- (BOOL)isArchived
{
  return [self.archived intValue];
}
- (void)setIsArchived:(BOOL)isArchived
{
  self.archived = [NSNumber numberWithInt:isArchived];
}

- (BOOL)isDeleted
{
  return [self.deleted intValue];
}
- (void)setIsDeleted:(BOOL)isDeleted
{
  self.deleted = [NSNumber numberWithInt:isDeleted];
}

- (BOOL)doSync
{
  return [self.sync intValue];
}
- (void)setDoSync:(BOOL)doSync
{
  self.sync = [NSNumber numberWithInt:doSync];
}

@end
