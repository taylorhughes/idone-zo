//
//  SyncTest.h
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface SyncTest : SenTestCase {
  NSManagedObjectContext *context;
}

@property (nonatomic, retain) NSManagedObjectContext *context;

@end
