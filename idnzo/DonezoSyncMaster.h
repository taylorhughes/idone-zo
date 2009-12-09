//
//  SyncMaster.h
//  DNZO
//
//  Created by Taylor Hughes on 8/4/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "DonezoAPIClient.h"

#import "Task.h"
#import "TaskList.h"
#import "Context.h"
#import "Project.h"

@interface DonezoSyncMaster : NSObject {
  DonezoAPIClient *client;
  NSManagedObjectContext *context;
  
  BOOL canceled;
}

@property (retain, nonatomic) DonezoAPIClient *client;
@property (retain, nonatomic) NSManagedObjectContext *context;

- (id) initWithDonezoClient:(DonezoAPIClient*)donezoClient andContext:(NSManagedObjectContext*)context;

- (void) syncAll:(NSError**)error;

- (NSArray*) syncLists:(NSError**)error;
- (void) syncList:(TaskList*)taskList error:(NSError**)error;

- (void) cancel;
- (BOOL) isCanceled;

@end
