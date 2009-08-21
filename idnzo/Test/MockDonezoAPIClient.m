//
//  MockDonezoAPIClient.m
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "MockDonezoAPIClient.h"

@interface MockDonezoAPIClient (Private)
- (BOOL)login:(NSError**)error;
- (NSString*)responseFromRequestToPath:(NSString*)path withMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error;
@end

@implementation MockDonezoAPIClient

- (void) loadTasksAndTaskLists:(NSString*)jsonData error:(NSError**)error
{
  [self resetAccount:error];
  
  // parse json into dictionary
  SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
  NSDictionary *dict = (NSDictionary*) [parser objectWithString:jsonData];
  NSMutableDictionary *dictLists = [NSMutableDictionary dictionary];
  
  // extract "task_lists" and add them to self.taskLists
  if ([dict objectForKey:@"task_lists"] != nil)
  {
    for (NSDictionary *listDict in (NSArray*)[dict objectForKey:@"task_lists"])
    {
      DonezoTaskList *list = [DonezoTaskList taskListFromDictionary:listDict];
      [self saveList:&list error:error];
      if (*error)
      {
        NSLog(@"Error saving list: %@", [*error description]);
        return;
      }
      [dictLists setValue:list forKey:list.key];
    }
  }
  
  if ([dict objectForKey:@"tasks"] != nil)
  {
    for (NSDictionary *taskDict in (NSArray*)[dict objectForKey:@"tasks"])
    {
      DonezoTask *task = [DonezoTask taskFromDictionary:taskDict];
      [self saveTask:&task taskList:[dictLists valueForKey:task.taskListKey] error:error];
    }    
  }
}

- (void) resetAccount:(NSError**)error
{
  [self login:error];
  [self responseFromRequestToPath:@"/reset_account/" withMethod:nil andBody:nil error:error];
}

@end
