//
//  Task.h
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "Context.h"

@class TaskList;
@class Project;
@class Context;

@interface Task :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber *key;
@property (nonatomic, retain) NSString *body;

@property (nonatomic, retain) NSDate *dueDate;
@property (nonatomic, retain) NSDate *completedAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *sortDate;

@property (nonatomic, retain) TaskList *taskList;
@property (nonatomic, retain) NSSet *contexts;
@property (nonatomic, retain) Project *project;

@property (readonly, nonatomic, copy) NSString *dueString;
@property (readonly, nonatomic, copy) NSString *contextsString;

// These properties modify underlying NSNumber* objects
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) BOOL isArchived;
@property (nonatomic, assign) BOOL isDeleted;
// Whether we should continue syncing this object
@property (nonatomic, assign) BOOL doSync;

- (NSArray *)contextNames;

// Updates updatedAt so we know to sync the new version properly
- (void) hasBeenUpdated:(NSDate*)newUpdatedAt;
- (void) hasBeenUpdated;

+ (NSDateFormatter *)dueDateFormatter;

@end


@interface Task (CoreDataGeneratedAccessors)
- (void)addContextsObject:(NSManagedObject *)value;
- (void)removeContextsObject:(NSManagedObject *)value;
- (void)addContexts:(NSSet *)value;
- (void)removeContexts:(NSSet *)value;
@end

