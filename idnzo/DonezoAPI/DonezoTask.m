//
//  DonezoTask.m
//  DNZO
//
//  Created by Taylor Hughes on 7/28/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "DonezoTask.h"

@implementation DonezoTask

@synthesize id;
@synthesize body;
@synthesize project;
@synthesize contexts;
@synthesize dueDate;

+ (DonezoTask*) taskFromDictionary:(NSDictionary*)dict
{
  DonezoTask *task = [[[DonezoTask alloc] init] autorelease];
  
  task.id = [dict valueForKey:@"id"];
  task.body = [dict valueForKey:@"body"];
  task.project = [dict valueForKey:@"project"];
  task.contexts = [dict valueForKey:@"contexts"];
  task.dueDate = [DonezoAPIClient dateFromDonezoDateString:[dict valueForKey:@"due_date"]];
    
  return task;
}

- (NSDictionary*) toDictionary
{
  NSString *contextsString = [self.contexts componentsJoinedByString:@","];
  NSString *dateString = [DonezoAPIClient donezoDateStringFromDate:self.dueDate];
  return [NSDictionary dictionaryWithObjectsAndKeys:
          self.id, @"id",
          self.body, @"body",
          self.project, @"project",
          contextsString, @"contexts",
          dateString, @"due_date",
          nil];
}

@end
