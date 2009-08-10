//
//  MockDonezoAPIClient.h
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "DonezoAPIClient.h"

@interface MockDonezoAPIClient : DonezoAPIClient {
  NSMutableArray *taskLists;
  NSMutableDictionary *tasks;
}

@property (retain, nonatomic) NSMutableArray *taskLists;
@property (retain, nonatomic) NSMutableDictionary *tasks;

- (void) setTasksAndTaskLists:(NSString*)jsonData;

@end
