//
//  SyncTest.h
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MockDonezoAPIClient.h"
#import "DonezoSyncMaster.h"

@interface SyncTest : SenTestCase {
  NSManagedObjectContext *context;
  NSString *tempPath;
  MockDonezoAPIClient *client;
  DonezoSyncMaster *syncMaster;
}

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, copy) NSString *tempPath;
@property (nonatomic, retain) MockDonezoAPIClient *client;
@property (nonatomic, retain) DonezoSyncMaster *syncMaster;

@end
