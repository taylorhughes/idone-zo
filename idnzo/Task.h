//
//  Task.h
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SQLitePersistentObject.h"

@class TaskList;

@interface Task : SQLitePersistentObject {
  
  TaskList *taskList;
  
  NSString *body;
  NSString *project;
  NSArray  *contexts;
  NSDate   *due;
  
}

@property (retain, nonatomic) TaskList *taskList;

@property (copy, nonatomic)   NSString *body;
@property (copy, nonatomic)   NSString *project;
@property (retain, nonatomic) NSArray  *contexts;
@property (copy, nonatomic)   NSDate   *due;

@end
