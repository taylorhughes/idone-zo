//
//  TaskFactoryTest.h
//  DNZO
//
//  Created by Taylor Hughes on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "DonezoAPIClient.h"
#import "DonezoAPIClient_Private.h"
#import "MockDonezoAPIClient.h"

@interface DonezoAPIClientTest : SenTestCase {
  DonezoAPIClient *client;
}

@property (nonatomic, retain) DonezoAPIClient *client;

@end
