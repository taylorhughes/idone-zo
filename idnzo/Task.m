//
//  Task.m
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

@implementation Task

@synthesize taskList;
@synthesize body, contexts, project, due;

+ (id) findByRemoteKey:(NSString *)aRemoteKey {
  return nil;
}

//+ (NSArray*) findAllByTaskList:(TaskList *)taskList {
//  return nil;
//}

@end
