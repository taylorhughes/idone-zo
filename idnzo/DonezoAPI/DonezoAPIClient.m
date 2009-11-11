//
//  DNZO.m
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "DonezoAPIClient.h"
#import "DonezoAPIClient_Private.h"

#define DEFAULT_BASE_URL @"http://www.done-zo.com/"
#define API_PATH @"/api/0.1/"
#define USER_AGENT_STRING @"Done-zo Client 0.1"

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
  [req setValue:USER_AGENT_STRING forHTTPHeaderField:@"User-Agent"];

  if (method != nil)
  {
    [req setHTTPMethod:method];
  }
  if (body != nil)
  {
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [req setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];    
  }
  
  NSHTTPURLResponse *response = nil;
  NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:error];      
  NSString *responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
  [req release];
  
  if (*error != nil)
  {
    return nil;
  }
  else if (response == nil || [response statusCode] >= 400)
  {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    NSString *errorString = [NSString stringWithFormat:@"Bad response code from Done-zo. The service seems to be unavailable."];
    [errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"DonezoAPI" code:100 userInfo:errorDetail];
    
    return nil;
  }
  
  return responseString;
}

- (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key error:(NSError**)error
{
  return [self getObjectFromPath:path withKey:key usingMethod:nil andBody:nil error:error];
}

- (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key usingMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error
{
  NSString *responseString = [self responseFromRequestToPath:path withMethod:method andBody:body error:error];
  
  if (*error != nil)
  {
    return nil;
  }
  
  NSDictionary *dict = [self parseDonezoResponse:responseString error:error];
  NSObject *obj = [dict objectForKey:key];
  if (*error == nil && obj == nil)
  {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    NSString *errorString = [NSString stringWithFormat:@"Could not find proper key in Done-zo response!"];
    [errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"DonezoAPI" code:100 userInfo:errorDetail];
    
    return nil;
  }
  
  return obj;
}

- (NSDictionary*)parseDonezoResponse:(NSString*)responseString error:(NSError**)error
{
  SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
  NSDictionary *dict = (NSDictionary*) [parser objectWithString:responseString];
  
  if (responseString != nil && ![responseString isEqualToString:@""] && dict == nil)
  {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    NSString *errorString = [NSString stringWithFormat:@"Response from Done-zo was not understood."];
    [errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"DonezoAPI" code:100 userInfo:errorDetail];
    
    return nil;
  }
  
  NSString *taskError = [dict valueForKey:@"error"];
  if (taskError != nil)
  {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    NSString *errorString = [NSString stringWithFormat:@"Got an error from Done-zo: %@", taskError];
    [errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"DonezoAPI" code:100 userInfo:errorDetail];
    
    return nil;
  }
  
  return dict;
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

- (NSArray*) getArchivedTasksCompletedBetweenDate:(NSDate*)start andDate:(NSDate*)finish error:(NSError**)error
{
  if (![self login:error]) { return nil; }

  NSString *startString  = [DonezoAPIClient donezoDetailedDateStringFromDate:start];
  NSString *finishString = [DonezoAPIClient donezoDetailedDateStringFromDate:finish];
  
  NSString *path = [NSString stringWithFormat:@"/a/?start_at=%@&end_at=%@", [startString urlencoded], [finishString urlencoded]];
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
  //NSString *result = 
  [self responseFromRequestToPath:path withMethod:@"DELETE" andBody:nil error:error];
  
  //NSLog(@"Result from DELETE: %@", result);
  
  if (*error)
  {
    return;
  }
  (*task).key = nil;
}


//                      for dates:        2009-08-03 00:00:00 
#define DONEZO_DATE_INPUT_FORMAT        @"yyyy-MM-dd HH:mm:ss"

#define DONEZO_DATE_OUTPUT_FORMAT       @"MM dd yyyy"
#define DONEZO_DATETIME_OUTPUT_FORMAT   @"yyyy-MM-dd HH:mm:ss"

+ (NSDate*) dateFromDonezoDateString:(NSString*)stringDate
{
  if (stringDate == nil || [stringDate isKindOfClass:[NSNull class]])
  {
    return nil;
  }

  NSDate *date = nil;
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  [formatter setDateFormat:DONEZO_DATE_INPUT_FORMAT];
  if ([stringDate rangeOfString:@"."].location == NSNotFound)
  {
    // no precision
    date = [formatter dateFromString:stringDate];
  }
  else
  {
    // NSDateFormatter ***ROUNDS TO MILLISECONDS***; manually add milliseconds instead
    NSArray *datePieces = [stringDate componentsSeparatedByString:@"."];
    stringDate = [datePieces objectAtIndex:0];
    NSTimeInterval interval = [(NSString*)[datePieces objectAtIndex:1] intValue] / 1000000.0;
    interval += [[formatter dateFromString:stringDate] timeIntervalSinceReferenceDate];
    
    date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:interval] autorelease];
  }
  return date;
}

+ (NSString*) donezoDetailedDateStringFromDate:(NSDate*)date
{
  if (date == nil || [date isKindOfClass:[NSNull class]])
  {
    return nil;
  }
  
  // NSDateFormatter ***ROUNDS TO MILLISECONDS IN OUTPUT***; manually add milliseconds instead
  NSTimeInterval interval = [date timeIntervalSinceReferenceDate];
  NSString *microseconds = [[[NSString stringWithFormat:@"%0.6f", interval] componentsSeparatedByString:@"."] objectAtIndex:1];
  
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  [formatter setDateFormat:DONEZO_DATETIME_OUTPUT_FORMAT];
  
  NSString *dateString = [NSString stringWithFormat:@"%@.%@", [formatter stringFromDate:date], microseconds];
  
  return dateString;
}

+ (NSString*) donezoDateStringFromDate:(NSDate*)date
{
  if (date == nil || [date isKindOfClass:[NSNull class]])
  {
    return nil;
  }
  
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  [formatter setDateFormat:DONEZO_DATE_OUTPUT_FORMAT];
  return [formatter stringFromDate:date];  
}

//- (NSArray*)getArchivedTasksFromDate:(NSDate*)start toDate:(NSDate*)finish error:(NSError**)error
//{
//  if (![self login:error]) { return nil; }
//  return nil;
//}

@end
