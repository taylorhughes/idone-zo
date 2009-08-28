//
//  DonezoTask.m
//  DNZO
//
//  Created by Taylor Hughes on 7/28/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "DonezoTask.h"

@implementation DonezoTask

@synthesize key;
@synthesize taskListKey;
@synthesize body;
@synthesize project;
@synthesize contexts;
@synthesize dueDate;
@synthesize updatedAt;
@synthesize isComplete;
@synthesize sortDate;

- (id) init
{
  self = [super init];
  if (self)
  {
    self.body = @"";
  }
  return self;
}

- (void) dealloc
{
  [key release];
  [taskListKey release];
  [body release];
  [project release];
  [contexts release];
  [dueDate release];
  [updatedAt release];
  [sortDate release];
  [super dealloc];
}

- (NSDictionary*) toDictionary
{
  NSString *sortString = [DonezoAPIClient donezoDetailedDateStringFromDate:self.sortDate];
  NSString *contextsString = [self.contexts componentsJoinedByString:@","];
  NSString *dateString = [DonezoAPIClient donezoDateStringFromDate:self.dueDate];
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  // assign these individually as any of them might be nil
  if (self.isComplete)
  {
    [dict setValue:@"true" forKey:@"complete"];
  }
  else
  {
    [dict setValue:@"false" forKey:@"complete"];
  }
  [dict setValue:self.body forKey:@"body"];
  [dict setValue:self.project forKey:@"project"];
  [dict setValue:contextsString forKey:@"contexts"];
  [dict setValue:dateString forKey:@"due_date"];
  [dict setValue:sortString forKey:@"sort_date"];
  
  if (self.key != nil)
  {
    [dict setValue:self.key forKey:@"id"];
  }
  return dict;
}

+ (DonezoTask*) taskFromDictionary:(NSDictionary*)dict
{
  DonezoTask *task = [[[DonezoTask alloc] init] autorelease];
  
  task.isComplete = (BOOL)[(NSNumber*)[dict valueForKey:@"complete"] intValue];
  task.key = [dict valueForKey:@"id"];
  task.taskListKey = [dict valueForKey:@"task_list"];
  task.body = [dict valueForKey:@"body"];
  task.project = [dict valueForKey:@"project"];
  
  if ([task.project isMemberOfClass:[NSNull class]])
  {
    task.project = nil;
  }
  task.contexts = [dict valueForKey:@"contexts"];
  if (!task.contexts || [task.contexts isMemberOfClass:[NSNull class]])
  {
    task.contexts = [NSArray array];
  }
  task.dueDate =   [DonezoAPIClient dateFromDonezoDateString:[dict valueForKey:@"due_date"]];
  task.updatedAt = [DonezoAPIClient dateFromDonezoDateString:[dict valueForKey:@"updated_at"]];
  NSString *sortDateStr = [dict valueForKey:@"sort_date"];
  //NSLog(@"Input sort date string: %@",sortDateStr);
  task.sortDate =  [DonezoAPIClient dateFromDonezoDateString:sortDateStr];
  //NSLog(@"Output sort date: %0.6f", [task.sortDate timeIntervalSinceReferenceDate]);
  
  return task;
}

@end
