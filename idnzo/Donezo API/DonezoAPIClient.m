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
@end

//#define BASE_URL @"http://www.done-zo.com/"
#define BASE_URL @"http://localhost:8081/"
#define API_PATH @"/api/0.1/"

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

- (BOOL) login:(NSError**)error
{
  if (self.gaeAuth.hasLoggedIn)
  {
    return YES;
  }
  return [self.gaeAuth login:error];
}

- (NSArray*)getLists:(NSError**)error
{
  if (![self login:error]) { return nil; }
  
  NSString *apiURL = [[NSString stringWithString:BASE_URL] stringByAppendingPathComponent:API_PATH];
  NSURL *listsURL = [NSURL URLWithString:[[NSString stringWithString:apiURL] stringByAppendingPathComponent:@"/l/"]];
  
  NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:listsURL];
  //[req setHTTPMethod:@"POST"];
  //[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
  //[req setHTTPBody:[postBody dataUsingEncoding:NSASCIIStringEncoding]];
  
  NSHTTPURLResponse *response;
  NSError *responseError = nil;
  NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&responseError];      
  NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
  
  SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
  NSDictionary *dict = (NSDictionary*) [parser objectWithString:responseString];
  
  NSString *taskError = [dict valueForKey:@"error"];
  if (taskError != nil)
  {
    NSLog(@"Task error: %@", taskError);
    return nil;
  }
  
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  
  NSLog(@"Here's the response: %@", dict);
  for (NSDictionary *taskListDict in [dict valueForKey:@"task_lists"])
  {
    NSLog(@"Here's a task list: %@", taskListDict);
    [array addObject:[DonezoTaskList taskListFromDictionary:taskListDict]];
  }
  
  return array;
}

- (NSArray*)getTasksForListWithKey:(NSString*)key error:(NSError**)error
{
  if (![self login:error]) { return nil; }
  return nil;
}

- (NSArray*)getArchivedTasksFromDate:(NSDate*)start toDate:(NSDate*)finish error:(NSError**)error
{
  if (![self login:error]) { return nil; }
  return nil;
}

@end
