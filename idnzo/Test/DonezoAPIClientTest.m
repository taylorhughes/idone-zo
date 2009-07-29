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
  GoogleAppEngineAuthenticator *auth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:[NSURL URLWithString:@"http://localhost:8081/"]
                                                                                   withUsername:@"some@user.com"
                                                                                    andPassword:@""];
  NSError *error = nil;
  BOOL result = [auth login:&error];
  STAssertTrue(result, @"Local login should not fail.");
  
  auth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:[NSURL URLWithString:@"http://www.done-zo.com/"]
                                                     withUsername:@"whorastic@hotmail.com"
                                                      andPassword:@"babel1234"];
  
  result = [auth login:&error];
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  /*
  STAssertTrue(result, @"Login should not fail.");
   */
}

- (void) testTaskLists
{
  DonezoAPIClient *client = [[DonezoAPIClient alloc] initWithUsername:@"test@example.com" andPassword:@""];
  
  NSError *error = nil;
  NSArray *array = [client getLists:&error];
  
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  
  STAssertEquals((NSUInteger)1, [array count], @"Count of task lists is wrong.");
  
  DonezoTaskList *list = (DonezoTaskList *)[array objectAtIndex:0];
  STAssertEqualObjects(@"Tasks", list.name, @"Task list should be 'Tasks'");
  STAssertEqualObjects(@"tasks", list.key, @"Task list key should be 'tasks'");
  STAssertEqualObjects([NSNumber numberWithInt:4], list.tasksCount, @"Tasks count should be 4.");
}

- (void) tearDown
{
}

@end