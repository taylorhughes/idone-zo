//
//  TaskFactoryTest.m
//  DNZO
//
//  Created by Taylor Hughes on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DonezoAPIClientTest.h"

#define TEST_URL      @"http://localhost:8081/"
#define TEST_USER     @"test@example.com"
#define TEST_PASSWORD @""
//#define TEST_URL      @"http://www.done-zo.com/"
//#define TEST_USER     @"whorastic@hotmail.com"
//#define TEST_PASSWORD @"testaccountpassword"

@implementation DonezoAPIClientTest

+ (void) setUp
{
}

- (void) setUp
{
}

- (void) tearDown
{
}

- (void) testLogin
{
  GoogleAppEngineAuthenticator *auth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:[NSURL URLWithString:TEST_URL]
                                                                                   withUsername:@"some@user.com"
                                                                                    andPassword:@""];
  NSError *error = nil;
  BOOL result = [auth login:&error];
  STAssertTrue(result, @"Local login should not fail.");
  
  auth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:[NSURL URLWithString:@"http://www.done-zo.com/"]
                                                     withUsername:@"whorastic@hotmail.com"
                                                      andPassword:@"testaccountpassword"];
  auth.appDescription = @"iDone-zo";
  
  result = [auth login:&error];
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  
  STAssertTrue(result, @"Login should not fail.");
}

- (DonezoAPIClient*)getClient
{
  // this is a secret api call.
  return [[DonezoAPIClient alloc] initWithUsername:TEST_USER andPassword:TEST_PASSWORD toBaseUrl:TEST_URL];
}

- (void) testTasks
{
  DonezoAPIClient *client = [self getClient];

  NSError *error = nil;
  NSArray *array = [client getTasksForListWithKey:@"tasks" error:&error];
  
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  
  STAssertTrue([array count] >= 4, @"Count of tasks is incorrect.");
  
  array = [client getTasksForListWithKey:@"not-a-list" error:&error];
  
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  
  STAssertEquals((NSUInteger)0, [array count], @"Count of tasks is incorrect.");
}

- (void) testInsertTask
{
  DonezoTask *newTask = [[[DonezoTask init] alloc] autorelease];
  newTask.body = [NSString stringWithFormat:@"My new task!! %@", [NSDate date]];
  newTask.project = @"Some project";
  newTask.contexts = [NSArray arrayWithObject:@"home"];
  newTask.dueDate = [NSDate date];
  
  DonezoAPIClient *client = [self getClient];
  NSError *error = nil;
  NSArray *array = [client getLists:&error];
  STAssertEquals((NSUInteger)1, [array count], @"getLists is not functioning properly");
  DonezoTaskList *list = [array objectAtIndex:0];
  
  array = [client getTasksForListWithKey:list.key error:&error];
  STAssertTrue([array count] > 0, @"getTasksForList is not functioning properly");
  for (DonezoTask *task in array)
  {
    if (task.body && ![task.body isMemberOfClass:[NSNull class]])
    {
      STAssertTrue(![task.body isEqualToString:newTask.body], @"No existing string should have the same body as this new one.");
    }
  }
  
  STAssertNil(newTask.key, @"New task's ID should be nil!");
  [client saveTask:&newTask taskList:list error:&error];
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  STAssertNotNil(newTask, @"New task should not be nil!");
  STAssertNotNil(newTask.key, @"New task's ID should not be nil after saving!");
  
  NSArray *newArray = [client getTasksForListWithKey:list.key error:&error];
  STAssertEquals([array count] + 1, [newArray count], @"There should be one more task in the new array of tasks");
  DonezoTask *newNewTask = nil;
  for (DonezoTask *task in newArray)
  {
    if ([task.key isEqualToNumber:newTask.key])
    {
      newNewTask = task;
    }
  }
  STAssertNotNil(newNewTask, @"Should have been able to find a matching new task in the getTasksForListWithKey method!");
  STAssertEqualObjects(newTask.body, newNewTask.body, @"New task's body was not saved properly.");
  STAssertNotNil(newNewTask.contexts, @"New contexts should not be null");
  STAssertEqualObjects(newTask.contexts, newNewTask.contexts, @"New task's contexts list was not saved properly.");
  STAssertNotNil(newNewTask.project, @"New project should not be null.");
  STAssertEqualObjects(newTask.project, newNewTask.project, @"New task's project was not saved properly.");
  STAssertNotNil(newNewTask.dueDate, @"New due date should not be null");
  STAssertEqualObjects(newTask.dueDate, newNewTask.dueDate, @"New task's due date was not saved properly.");
}

- (void) testUpdateTask
{
  DonezoAPIClient *client = [self getClient];
  NSError *error = nil;
  NSArray *array = [client getLists:&error];
  STAssertEquals((NSUInteger)1, [array count], @"getLists is not functioning properly");
  DonezoTaskList *list = [array objectAtIndex:0];
  
  array = [client getTasksForListWithKey:list.key error:&error];
  STAssertTrue([array count] > 0, @"getTasksForList is not functioning properly");
  NSString *appendage = @" !!!";
  for (DonezoTask *task in array)
  {
    if (task.body && ![task.body isMemberOfClass:[NSNull class]])
    {
      task.body = [task.body stringByAppendingString:appendage];
      [client saveTask:&task taskList:list error:&error];
    }
  }
  
  NSArray *newArray = [client getTasksForListWithKey:list.key error:&error];
  for (int i = 0; i < [newArray count]; i++)
  {
    DonezoTask *taskA = (DonezoTask*)[array objectAtIndex:i];
    DonezoTask *taskB = (DonezoTask*)[newArray objectAtIndex:i];
    STAssertEqualObjects(taskA.body, taskB.body, @"Task bodies should be the same!");
  }
}

- (void) testTaskLists
{
  DonezoAPIClient *client = [self getClient];
  
  NSError *error = nil;
  NSArray *array = [client getLists:&error];
  
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  
  STAssertEquals((NSUInteger)1, [array count], @"Count of task lists is incorrect.");
  
  DonezoTaskList *list = (DonezoTaskList *)[array objectAtIndex:0];
  STAssertEqualObjects(@"Tasks", list.name, @"Task list should be 'Tasks'");
  STAssertEqualObjects(@"tasks", list.key, @"Task list key should be 'tasks'");
  STAssertTrue([list.tasksCount intValue] >= 4, @"Tasks count should be at least 4.");
}

@end