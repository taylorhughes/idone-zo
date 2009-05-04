//
//  TaskList.h
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DNZODataObject.h"
#import <sqlite3.h>

@class Task, DNZODataObject;

@interface TaskList : DNZODataObject {
  NSString *name;
  NSArray  *tasks;
}

@property (copy, nonatomic)   NSString *name;
@property (retain, nonatomic) NSArray  *tasks;

// Static members
+ (NSArray*) findAll;
+ (id) findByRemoteKey:(NSString*)remoteKey;

- (id) initWithPrimaryKey:(NSInteger)key;
- (void) addTask:(Task*)task;
- (void) removeTask:(Task*)task;

@end
