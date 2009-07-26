//
//  TaskFactoryTest.m
//  DNZO
//
//  Created by Taylor Hughes on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DonezoAPIClientTest.h"

@implementation DonezoAPIClientTest

+ (void) setUp
{
}

- (void) setUp
{
}

- (void) testLogin
{
  GoogleAppEngineAuthenticator *auth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:[NSURL URLWithString:@"http://www.done-zo.com/"]
                                                                                   withUsername:@"whorastic@hotmail.com"
                                                                                    andPassword:@"somepassword"];
  BOOL result = [auth login];
  STAssertEquals(YES, result, @"Login should not fail.");
}

- (void) tearDown
{
}

@end