//
//  Task.h
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DNZODataObject.h"

@class TaskList;

@interface Task : DNZODataObject {
  
  TaskList *taskList;
  
  NSString *body;
  NSString *project;
  NSArray  *contexts;
  NSDate   *due;
  
}

@property (retain, nonatomic, readonly) TaskList *taskList;

@property (copy, nonatomic)   NSString *body;
@property (copy, nonatomic)   NSString *project;
@property (retain, nonatomic) NSArray  *contexts;
@property (copy, nonatomic)   NSDate   *due;

// Static members
//+ (NSArray*) findAllByTaskList:(TaskList*)taskList;
+ (id) findByRemoteKey:(NSString*)remoteKey;

@end
