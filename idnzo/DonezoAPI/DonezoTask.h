//
//  DonezoTask.h
//  DNZO
//
//  Created by Taylor Hughes on 7/28/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "DonezoAPIClient.h"

@interface DonezoTask : NSObject {
  NSNumber *id;
  NSString *body;
  NSString *project;
  NSArray  *contexts;
  NSDate   *dueDate;
}

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *project;
@property (nonatomic, copy) NSArray  *contexts;
@property (nonatomic, copy) NSDate   *dueDate;

+ (DonezoTask*) taskFromDictionary:(NSDictionary*)dict;
- (NSDictionary*) toDictionary;

@end
