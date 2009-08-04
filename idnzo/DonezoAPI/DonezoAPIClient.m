//
//  DNZO.m
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DonezoAPIClient.h"

@interface DonezoAPIClient (Private)
- (BOOL) login;
+ (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key error:(NSError**)error;
+ (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key usingMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error;
+ (NSString*)responseFromRequestToPath:(NSString*)path withMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error;
@end

//#define BASE_URL @"http://www.done-zo.com/"
#define BASE_URL @"http://localhost:8081/"
#define API_PATH @"/api/0.1/"
#define API_URL [[NSString stringWithString:BASE_URL] stringByAppendingPathComponent:API_PATH]

@implementation DonezoAPIClient

@synthesize gaeAuth;

- (id)initWithUsername:(NSString*)username andPassword:(NSString*)password
{
  self = [super init];
  if (self != nil)
  {
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    self.gaeAuth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:baseURL withUsername:username andPassword:password];
  }
  return self;
}

- (void) dealloc
{
  [gaeAuth release];
  [super dealloc];
}

- (BOOL) login:(NSError**)error
{
  if (self.gaeAuth.hasLoggedIn)
  {
    return YES;
  }
  return [self.gaeAuth login:error];
}


+ (NSString*)responseFromRequestToPath:(NSString*)path withMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error
{
  NSURL *url = [NSURL URLWithString:[API_URL stringByAppendingPathComponent:path]];
  NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
  
  if (method != nil)
  {
    [req setHTTPMethod:method];
  }
  if (body != nil)
  {
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [req setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];    
  }
  
  NSHTTPURLResponse *response;
  NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:error];      
  NSString *responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
  
  //NSLog(@"Here's the response: %@", responseString);
  
  return responseString;
}

+ (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key error:(NSError**)error
{
  return [DonezoAPIClient getObjectFromPath:path withKey:key usingMethod:nil andBody:nil error:error];
}
  
+ (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key usingMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error
{
  NSString *responseString = [DonezoAPIClient responseFromRequestToPath:path withMethod:method andBody:body error:error];
  
  if (*error)
  {
    NSLog(@"Ruh roh! Error! %@", *error);
    return nil;
  }
  
  SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
  NSDictionary *dict = (NSDictionary*) [parser objectWithString:responseString];
  
  NSString *taskError = [dict valueForKey:@"error"];
  if (taskError != nil)
  {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    NSString *errorString = [NSString stringWithFormat:@"Got an error from Done-zo: %@", taskError];
    [errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"DonezoAPI" code:100 userInfo:errorDetail];
    
    return nil;
  }
  
  return [dict objectForKey:key];
}

- (NSArray*)getLists:(NSError**)error
{
  if (![self login:error]) { return nil; }
  
  NSArray *taskLists = (NSArray*) [DonezoAPIClient getObjectFromPath:@"/l/" withKey:@"task_lists" error:error];
  
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  for (NSDictionary *taskListDict in taskLists)
  {
    //NSLog(@"Here's a task list: %@", taskListDict);
    [array addObject:[DonezoTaskList taskListFromDictionary:taskListDict]];
  }
  
  return array;
}

- (NSArray*)getTasksForListWithKey:(NSString*)key error:(NSError**)error
{
  if (![self login:error]) { return nil; }
  
  NSString *path = [NSString stringWithFormat:@"/t/?task_list=%@", [key urlencoded]];
  NSArray *tasks = (NSArray*) [DonezoAPIClient getObjectFromPath:path withKey:@"tasks" error:error];
  
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  for (NSDictionary *tasksDict in tasks)
  {
    [array addObject:[DonezoTask taskFromDictionary:tasksDict]];
  }
  
  return array;
}


- (void) saveTask:(DonezoTask**)task taskList:(DonezoTaskList*)list error:(NSError**)error
{
  if (![self login:error]) { return; }
  
  NSString *path;
  NSString *method;
  if ((*task).key != nil)
  {
    // existing task; modify
    path = [NSString stringWithFormat:@"/t/%@/", (*task).key];
    method = @"PUT";
  }
  else
  {
    // new task; insert
    path = [NSString stringWithFormat:@"/t/?task_list=%@", [list.key urlencoded]];
    method = @"POST";
  }
  
  NSDictionary *dict = [*task toDictionary];
  //NSLog(@"Dict looks like %@", dict);
  NSString *body = [dict toFormEncodedString];
  
  NSLog(@"Body looks like %@", body);
  dict = (NSDictionary*)[DonezoAPIClient getObjectFromPath:path withKey:@"task" usingMethod:method andBody:body error:error];
  
  if (*error)
  {
    return;
  }
  *task = [DonezoTask taskFromDictionary:dict];
}

- (void) deleteTask:(DonezoTask**)task error:(NSError**)error
{
  if (![self login:error]) { return; }
  
  
}

//                                  2009-08-03 22:34:23.216692
#define DONEZO_DATE_INPUT_FORMAT  @"yyyy-MM-dd HH:mm:SSSSSSSSS"
#define DONEZO_DATE_OUTPUT_FORMAT @"MM dd yyyy"

+ (NSDate*) dateFromDonezoDateString:(NSString*)stringDate
{
  if (stringDate == nil || [stringDate isKindOfClass:[NSNull class]])
  {
    return nil;
  }
  
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setDateFormat:DONEZO_DATE_INPUT_FORMAT];
  return [formatter dateFromString:stringDate];
}

+ (NSString*) donezoDateStringFromDate:(NSDate*)date
{
  if (date == nil || [date isKindOfClass:[NSNull class]])
  {
    return nil;
  }
  
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setDateFormat:DONEZO_DATE_OUTPUT_FORMAT];
  return [formatter stringFromDate:date];  
}

//- (NSArray*)getArchivedTasksFromDate:(NSDate*)start toDate:(NSDate*)finish error:(NSError**)error
//{
//  if (![self login:error]) { return nil; }
//  return nil;
//}

@end