//
//  SyncMaster.h
//  DNZO
//
//  Created by Taylor Hughes on 8/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DonezoAPIClient.h"

#import "Task.h"
#import "TaskList.h"
#import "Context.h"
#import "Project.h"

@interface DonezoSyncMaster : NSObject {
  DonezoAPIClient *client;
  NSManagedObjectContext *context;
}

@property (retain, nonatomic) DonezoAPIClient *client;
@property (retain, nonatomic) NSManagedObjectContext *context;

- (id) initWithDonezoClient:(DonezoAPIClient*)donezoClient andContext:(NSManagedObjectContext*)context;
- (void) performSync:(NSError**)error;

@end