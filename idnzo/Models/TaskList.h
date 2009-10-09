//
//  TaskList.h
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "DNZOAppDelegate.h"

@class Task;

@interface TaskList : NSManagedObject  
{
 @private
  NSFetchRequest *tasksForListRequest;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSSet *tasks;

@property (nonatomic, readonly) NSFetchRequest *tasksForListRequest;
@property (nonatomic, readonly) NSUInteger displayTasksCount;

@end

@interface TaskList (CoreDataGeneratedAccessors)

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

@end

