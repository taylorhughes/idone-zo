//
//  MockDonezoAPIClient.h
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "DonezoAPIClient.h"
#import "JSON.h"

@interface MockDonezoAPIClient : DonezoAPIClient {
}

- (void) loadTasksAndTaskLists:(NSString*)jsonData error:(NSError**)error;
- (void) resetAccount:(NSError**)error;

@end
