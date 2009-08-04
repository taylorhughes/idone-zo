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
@synthesize body;
@synthesize project;
@synthesize contexts;
@synthesize dueDate;

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
  [body release];
  [project release];
  [contexts release];
  [dueDate release];
  [super dealloc];
}

- (NSDictionary*) toDictionary
{
  NSString *contextsString = [self.contexts componentsJoinedByString:@","];
  NSString *dateString = [DonezoAPIClient donezoDateStringFromDate:self.dueDate];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  // do it this way instead of mass assignment because some might be nil
  [dict setValue:self.body forKey:@"body"];
  [dict setValue:self.project forKey:@"project"];
  [dict setValue:contextsString forKey:@"contexts"];
  [dict setValue:dateString forKey:@"due_date"];  
  if (self.key != nil)
  {
    [dict setValue:self.key forKey:@"id"];
  }
  return dict;
}

+ (DonezoTask*) taskFromDictionary:(NSDictionary*)dict
{
  DonezoTask *task = [[[DonezoTask alloc] init] autorelease];
  
  task.key = [dict valueForKey:@"id"];
  task.body = [dict valueForKey:@"body"];
  task.project = [dict valueForKey:@"project"];
  task.contexts = [dict valueForKey:@"contexts"];
  task.dueDate = [DonezoAPIClient dateFromDonezoDateString:[dict valueForKey:@"due_date"]];
  
  return task;
}

@end