//
//  DonezoTask.h
//  DNZO
//
//  Created by Taylor Hughes on 7/28/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "DonezoAPIClient.h"

@interface DonezoTask : NSObject {
  NSNumber *key;
  NSString *taskListKey;
  NSString *body;
  NSString *project;
  NSArray  *contexts;
  NSDate   *dueDate;
  NSDate   *updatedAt;
  NSDate   *sortDate;
  BOOL      isComplete;
}

@property (nonatomic, copy) NSNumber *key;
@property (nonatomic, copy) NSString *taskListKey;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *project;
@property (nonatomic, copy) NSArray  *contexts;
@property (nonatomic, copy) NSDate   *dueDate;
@property (nonatomic, copy) NSDate   *updatedAt;
@property (nonatomic, copy) NSDate   *sortDate;
@property (nonatomic, assign) BOOL    isComplete;

+ (DonezoTask*) taskFromDictionary:(NSDictionary*)dict;
- (NSDictionary*) toDictionary;

@end
