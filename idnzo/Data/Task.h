//
//  Task.h
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SQLitePersistentObject.h"

@class Project, TaskList, SQLitePersistentObject;

@interface Task : SQLitePersistentObject {
  
  TaskList *taskList;
  
  NSString *body;
  Project  *project;
  NSArray  *contexts;
  NSDate   *due;
  
  BOOL      complete;
  
}

@property (retain, nonatomic) TaskList *taskList;

@property (copy, nonatomic)   NSString *body;
@property (retain, nonatomic) Project  *project;
@property (retain, nonatomic) NSArray  *contexts;
@property (copy, nonatomic)   NSDate   *due;
@property (assign, nonatomic) BOOL      complete;

- (NSString *)contextsString;
- (NSString *)dueString;

@end
