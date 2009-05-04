//
//  TaskList.m
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskList.h"

@implementation TaskList

@synthesize name, tasks;

+ (NSArray*) findAll {
  NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:50];
  
  const char *findSQL = "SELECT key FROM task_lists";
  sqlite3_stmt *statement;
  
  NSInteger key;
  TaskList *taskList;
  if (sqlite3_prepare_v2([DNZODataObject database], findSQL, -1, &statement, NULL) == SQLITE_OK) {
    while (sqlite3_step(statement) == SQLITE_ROW) {
      key = sqlite3_column_int(statement, 0);
      taskList = [[TaskList alloc] initWithPrimaryKey:key];
      [tasks addObject:taskList];
      [taskList release];
    }
  }
  
  return [NSArray arrayWithArray:tasks];
}

+ (id) findByRemoteKey:(NSString*)remoteKey {
  return nil;
}

- (id) initWithPrimaryKey:(NSInteger) pk {
  if (self = [super init]) {
    const char* findSQL = "SELECT key, remote_key, name FROM task_lists WHERE key=?";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2([DNZODataObject database], findSQL, -1, &statement, NULL) == SQLITE_OK) {
      sqlite3_bind_int(statement, 1, pk);
      if (sqlite3_step(statement) == SQLITE_ROW) {
        // Assign this directly
        key = sqlite3_column_int(statement, 0);
        char* rk = (char *)sqlite3_column_text(statement, 1);
        // Remote key might be nil
        if (rk) {
          self.remoteKey = [NSString stringWithUTF8String:rk];
        }
        // Name should never be nil
        self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
      } else {
        self.name = @"Unknown";
      }
    }    
  }
  return self;
}

- (void) addTask:(Task*)task {
  
}
- (void) removeTask:(Task*)task {
  
}

@end
