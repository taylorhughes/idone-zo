//
//  DNZO.m
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DonezoAPIClient.h"

@interface DonezoAPIClient ()
@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, readonly) NSString *apiUrl;

- (BOOL)login:(NSError**)error;
- (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key error:(NSError**)error;
- (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key usingMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error;
- (NSString*)responseFromRequestToPath:(NSString*)path withMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error;

@end

#define DEFAULT_BASE_URL @"http://www.done-zo.com/"
#define API_PATH @"/api/0.1/"

@implementation DonezoAPIClient

@synthesize gaeAuth;
@synthesize baseUrl;

- (id)initWithUsername:(NSString*)username andPassword:(NSString*)password toBaseUrl:(NSString*)baseURL
{
  self = [super init];
  if (self != nil)
  {
    if (baseURL == nil)
    {
      baseURL = DEFAULT_BASE_URL;
    }
    self.baseUrl = baseURL;
    self.gaeAuth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:[NSURL URLWithString:baseURL]
                                                                     toPath:API_PATH
                                                               withUsername:username
                                                                andPassword:password];
  }
  return self;
}

- (id)initWithUsername:(NSString*)username andPassword:(NSString*)password
{
  return [self initWithUsername:username andPassword:password toBaseUrl:nil];
}

- (void) dealloc
{
  [gaeAuth release];
  [baseUrl release];
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

- (NSString*)apiUrl
{
  return [[NSString stringWithString:self.baseUrl] stringByAppendingPathComponent:API_PATH];
}

- (NSString*)responseFromRequestToPath:(NSString*)path withMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error
{  
  NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingPathComponent:path]];
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
    
  return responseString;
}

- (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key error:(NSError**)error
{
  return [self getObjectFromPath:path withKey:key usingMethod:nil andBody:nil error:error];
}
  
- (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key usingMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error
{
  NSString *responseString = [self responseFromRequestToPath:path withMethod:method andBody:body error:error];
  
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
  
  NSArray *taskLists = (NSArray*) [self getObjectFromPath:@"/l/" withKey:@"task_lists" error:error];
  
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  for (NSDictionary *taskListDict in taskLists)
  {
    //NSLog(@"Here's a task list: %@", taskListDict);
    [array addObject:[DonezoTaskList taskListFromDictionary:taskListDict]];
  }
  
  return array;
}

- (DonezoTaskList*) getListWithKey:(NSString*)key error:(NSError**)error
{
  NSArray *lists = [self getLists:error];
  for (DonezoTaskList *list in lists)
  {
    if ([list.key isEqualToString:key])
    {
      return list;
    }
  }
  return nil;
}

- (void) saveList:(DonezoTaskList**)list error:(NSError**)error
{
  if (![self login:error]) { return; }
  
  if ((*list).key != nil)
  {
    // lists are immutable
    NSMutableDictionary *errorDetail = [NSDictionary dictionaryWithObject:@"Done-zo task lists are immutable." forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"DonezoAPI" code:100 userInfo:errorDetail];
    
    return;
  }

  NSString *body = [[NSDictionary dictionaryWithObject:(*list).name forKey:@"task_list_name"] toFormEncodedString];
  
  //NSLog(@"Body looks like %@", body);
  NSDictionary *dict = (NSDictionary*)[self getObjectFromPath:@"/l/" withKey:@"task_list" usingMethod:@"POST" andBody:body error:error];
  
  if (*error)
  {
    return;
  }
  *list = [DonezoTaskList taskListFromDictionary:dict];
}

- (void) deleteList:(DonezoTaskList**)list error:(NSError**)error
{
  if (![self login:error]) { return; }
  
  NSString *path = [NSString stringWithFormat:@"/l/%@/", (*list).key];  
  [self responseFromRequestToPath:path withMethod:@"DELETE" andBody:nil error:error];
  
  //NSLog(@"Result from DELETE: %@", result);
  
  if (*error)
  {
    return;
  }
  (*list).key = nil;
}


- (NSArray*)getTasksForListWithKey:(NSString*)key error:(NSError**)error
{
  if (![self login:error]) { return nil; }
  
  NSString *path = [NSString stringWithFormat:@"/t/?task_list=%@", [key urlencoded]];
  NSArray *tasks = (NSArray*) [self getObjectFromPath:path withKey:@"tasks" error:error];
  
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
  
  //NSLog(@"Body looks like %@", body);
  dict = (NSDictionary*)[self getObjectFromPath:path withKey:@"task" usingMethod:method andBody:body error:error];
  
  if (*error)
  {
    return;
  }
  *task = [DonezoTask taskFromDictionary:dict];
}

- (void) deleteTask:(DonezoTask**)task error:(NSError**)error
{
  if (![self login:error]) { return; }
  
  NSString *path = [NSString stringWithFormat:@"/t/%@/", (*task).key];  
  NSString *result = [self responseFromRequestToPath:path withMethod:@"DELETE" andBody:nil error:error];
  
  NSLog(@"Result from DELETE: %@", result);
  
  if (*error)
  {
    return;
  }
  (*task).key = nil;
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
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	[formatter setTimeZone:timeZone];
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
