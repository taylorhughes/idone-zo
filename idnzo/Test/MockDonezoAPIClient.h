//
//  MockDonezoAPIClient.h
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "DonezoAPIClient.h"

@interface MockDonezoAPIClient : DonezoAPIClient {
  NSArray *taskLists;
  NSDictionary *tasks;
}

@property (retain, nonatomic) NSArray *taskLists;
@property (retain, nonatomic) NSDictionary *tasks;

- (void) setTasksAndTaskLists:(NSString*)jsonData;

@end
