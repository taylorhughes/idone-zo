//
//  TaskFactoryTest.m
//  DNZO
//
//  Created by Taylor Hughes on 4/28/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "DonezoAPIClientTest.h"

#define TEST_URL      @"http://localhost:8081/"
#define TEST_USER     @"testuser@example.com"
#define TEST_PASSWORD @""
//#define TEST_URL      @"http://www.done-zo.com/"
//#define TEST_USER     @"whorastic@hotmail.com"
//#define TEST_PASSWORD @"testaccountpassword"

@implementation DonezoAPIClientTest

@synthesize client;

- (void) setUp
{
  NSError *error = nil;
  
  self.client = [[MockDonezoAPIClient alloc] initWithUsername:TEST_USER andPassword:TEST_PASSWORD toBaseUrl:TEST_URL];
  [(MockDonezoAPIClient*)self.client resetAccount:&error];
  
  if (error)
  {
    NSLog(@"Could not reset account! %@ %@", [error description], [error userInfo]);    
  }

  
  [(MockDonezoAPIClient*)self.client loadTasksAndTaskLists:@"{ \
   \"task_lists\": [ \
   { \"name\": \"Tasks\" } \
   ], \
   \"tasks\": [ \
   { \"body\": \"A remote task in Tasks.\", \"task_list\": \"tasks\", \"project\": \"Some project\" }, \
   { \"body\": \"A second remote task in Tasks!\", \"task_list\": \"tasks\", \"contexts\": [\"home\", \"work\"] } \
   ] \
   }" error:&error];
}

- (void) testDateFormatters
{
  NSDate *now = [NSDate date];
  
  NSString *dateString = [DonezoDates donezoDetailedDateStringFromDate:now];
  NSDate *mangledNow = [DonezoDates dateFromDonezoDateString:dateString];
  
  NSString *a = [NSString stringWithFormat:@"%0.6f", [now timeIntervalSinceReferenceDate]];
  NSString *b = [NSString stringWithFormat:@"%0.6f", [mangledNow timeIntervalSinceReferenceDate]];
  
  STAssertEqualObjects(a, b, @"Date is not toString'd and then unparsed properly.");
}

- (void) testLogin
{
  GoogleAppEngineAuthenticator *auth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:[NSURL URLWithString:TEST_URL]
                                                                                   withUsername:@"some@user.com"
                                                                                    andPassword:@""];
  NSError *error = nil;
  BOOL result = [auth login:&error];
  STAssertTrue(result, @"Local login should not fail.");
  
  /*
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
  */
}

- (void) testBadResponseString
{
  NSError *error = nil;
  NSDictionary *dict = [self.client parseDonezoResponse:@"500 server errorz" error:&error];
  
  STAssertTrue(error != nil, @"Bad response should produce an error!");
  STAssertNil(dict, @"Returning dict object should be nil!");
}

- (void) testTasks
{
  NSError *error = nil;
  NSArray *array = [self.client getTasksForListWithKey:@"tasks" error:&error];
  
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  
  STAssertEquals((NSUInteger)2, [array count], @"Tasks count should be 2.");  
  array = [self.client getTasksForListWithKey:@"not-a-list" error:&error];
  
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  
  STAssertEquals((NSUInteger)0, [array count], @"Count of tasks for missing list should be 0.");
}

- (void) testInsertTask
{
  DonezoTask *originalTask = [[[DonezoTask init] alloc] autorelease];
  originalTask.body = [NSString stringWithFormat:@"My new task!! %@", [NSDate date]];
  originalTask.project = @"Some project";
  originalTask.contexts = [NSArray arrayWithObject:@"home"];
  originalTask.dueDate = [NSDate date];
  originalTask.sortDate = [NSDate date];
  DonezoTask *newTask = originalTask;
  
  NSError *error = nil;
  NSArray *array = [self.client getLists:&error];
  STAssertEquals((NSUInteger)1, [array count], @"getLists is not functioning properly");
  DonezoTaskList *list = [array objectAtIndex:0];
  
  array = [self.client getTasksForListWithKey:list.key error:&error];
  STAssertTrue([array count] > 0, @"getTasksForList is not functioning properly");
  for (DonezoTask *task in array)
  {
    if (task.body && ![task.body isMemberOfClass:[NSNull class]])
    {
      STAssertTrue(![task.body isEqualToString:newTask.body], @"No existing string should have the same body as this new one.");
    }
  }
  
  STAssertNil(newTask.key, @"New task's ID should be nil!");
  [self.client saveTask:&newTask taskList:list error:&error];
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  STAssertNotNil(newTask, @"New task should not be nil!");
  STAssertNotNil(newTask.key, @"New task's ID should not be nil after saving!");
  
  NSArray *newArray = [self.client getTasksForListWithKey:list.key error:&error];
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
  STAssertEqualObjects(originalTask.body, newNewTask.body, @"New task's body was not saved properly.");
  STAssertNotNil(newNewTask.contexts, @"New contexts should not be null");
  STAssertEqualObjects(originalTask.contexts, newNewTask.contexts, @"New task's contexts list was not saved properly.");
  STAssertNotNil(newNewTask.project, @"New project should not be null.");
  STAssertEqualObjects(originalTask.project, newNewTask.project, @"New task's project was not saved properly.");
  STAssertNotNil(newNewTask.dueDate, @"New due date should not be null");
  STAssertEqualObjects([DonezoDates donezoDateStringFromDate:originalTask.dueDate], [DonezoDates donezoDateStringFromDate:newNewTask.dueDate], @"New task's due date was not saved properly.");
  STAssertNotNil(newNewTask.sortDate, @"New sort date should not be null");
  NSString *a = [NSString stringWithFormat:@"%0.6f", [originalTask.sortDate timeIntervalSinceReferenceDate]];
  NSString *b = [NSString stringWithFormat:@"%0.6f", [newNewTask.sortDate timeIntervalSinceReferenceDate]];
  STAssertEqualObjects(a, b, @"New task's sort date was not saved properly.");
  NSLog(@"A and B: %@ / %@", a, b);
}

- (void) testUpdateTask
{
  NSError *error = nil;
  NSArray *array = [self.client getLists:&error];
  STAssertEquals((NSUInteger)1, [array count], @"getLists is not functioning properly");
  DonezoTaskList *list = [array objectAtIndex:0];
  
  array = [self.client getTasksForListWithKey:list.key error:&error];
  STAssertTrue([array count] > 0, @"getTasksForList is not functioning properly");
  NSString *appendage = @" !!!";
  for (DonezoTask *task in array)
  {
    if (task.body && ![task.body isMemberOfClass:[NSNull class]])
    {
      task.body = [task.body stringByAppendingString:appendage];
      [self.client saveTask:&task taskList:list error:&error];
    }
  }
  
  NSArray *newArray = [self.client getTasksForListWithKey:list.key error:&error];
  for (int i = 0; i < [newArray count]; i++)
  {
    DonezoTask *taskA = (DonezoTask*)[array objectAtIndex:i];
    DonezoTask *taskB = (DonezoTask*)[newArray objectAtIndex:i];
    STAssertEqualObjects(taskA.body, taskB.body, @"Task bodies should be the same!");
  }
}

- (void) testArchivedTasks
{ 
  NSError *error = nil;
  
  DonezoTaskList *list = [[self.client getLists:&error] objectAtIndex:0];
  NSArray *tasks = [self.client getTasksForListWithKey:list.key error:&error];

  NSUInteger archived = 0;
  NSUInteger unarchived = [tasks count];
  
  NSDate *start = [NSDate dateWithTimeIntervalSinceNow:-60];
  NSDate *end =   [NSDate dateWithTimeIntervalSinceNow:600];
  
  NSArray *archivedTasks = [self.client getArchivedTasksCompletedBetweenDate:start andDate:end error:&error];
  STAssertEquals((NSUInteger)0, [archivedTasks count], @"Archived tasks count should be zero at the start.");
  
  for (DonezoTask *task in tasks)
  {
    task.isComplete = YES;
    task.isArchived = YES;
    [self.client saveTask:&task taskList:list error:&error];
    
    STAssertNil(error, @"Error should be nil but was %@", error);
    
    unarchived -= 1;
    archived += 1;

    archivedTasks = [self.client getArchivedTasksCompletedBetweenDate:start andDate:end error:&error];
    NSArray *remainingTasks = [self.client getTasksForListWithKey:list.key error:&error];
    
    STAssertEquals(archived, [archivedTasks count], @"Archived tasks count is wrong; was %d, should be %d", [archivedTasks count], archived);
    STAssertEquals(unarchived, [remainingTasks count], @"Remaining tasks count is wrong; was %d, should be %d", [remainingTasks count], unarchived);
  }

}

- (void) testTaskLists
{
  NSError *error = nil;
  NSArray *array = [self.client getLists:&error];
  
  if (error != nil)
  {
    NSLog(@"Error! %@", [error description]);
  }
  
  STAssertEquals((NSUInteger)1, [array count], @"Count of task lists is incorrect.");
  
  DonezoTaskList *list = (DonezoTaskList *)[array objectAtIndex:0];
  STAssertEqualObjects(@"Tasks", list.name, @"Task list should be 'Tasks'");
  STAssertEqualObjects(@"tasks", list.key, @"Task list key should be 'tasks'");
  STAssertEquals(2, [list.tasksCount intValue], @"Tasks count should be 2.");
}


@end