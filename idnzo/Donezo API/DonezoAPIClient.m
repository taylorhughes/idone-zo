//
//  DNZO.m
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DonezoAPIClient.h"

@interface DonezoAPIClient (Private)
- (void) login;
@end

//#define API_URL @"http://www.done-zo.com/api/0.1/"
#define API_URL @"http://localhost:8081/api/0.1/"

@implementation DonezoAPIClient

@synthesize gaeAuth;

- (id)initWithUsername:(NSString*)username andPassword:(NSString*)password
{
  self = [super init];
  if (self != nil)
  {
    NSURL *url = [NSURL URLWithString:API_URL];
    self.gaeAuth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:url withUsername:username andPassword:password];
  }
  return self;
}

- (void) login:(NSError**)error
{
  if (self.gaeAuth.hasLoggedIn)
  {
    return;
  }
  [self.gaeAuth login:error];
}

- (NSArray*)getLists:(NSError**)error
{
  [self login:error];
  return nil;
}

- (NSArray*)getTasksForListWithKey:(NSString*)key error:(NSError**)error
{
  [self login:error];
  return nil;
}

- (NSArray*)getArchivedTasksFromDate:(NSDate*)start toDate:(NSDate*)finish error:(NSError**)error
{
  [self login:error];
  return nil;
}

@end
