//
//  DonezoTaskList.h
//  DNZO
//
//  Created by Taylor Hughes on 7/28/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

@interface DonezoTaskList : NSObject {
  NSString *key;
  NSString *name;
  NSNumber *tasksCount;
}

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *tasksCount;

+ (DonezoTaskList*) taskListFromDictionary:(NSDictionary*)dict;
- (NSDictionary*) toDictionary;

@end
