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

@implementation DonezoAPIClient

@synthesize gaeAuth;

- (id)initWithUsername:(NSString*)username andPassword:(NSString*)password
{
  self = [super init];
  if (self != nil)
  {
    NSURL *url = [NSURL URLWithString:@"http://www.done-zo.com/"];
    self.gaeAuth = [[GoogleAppEngineAuthenticator alloc] initForGAEAppAtUrl:url withUsername:username andPassword:password];
  }
  return self;
}

- (void) login
{
  if (self.gaeAuth.hasLoggedIn)
  {
    return;
  }
  [self.gaeAuth login];
}

- (NSArray*)getLists
{
  [self login];
  return nil;
}

- (NSArray*)getTasksForListWithKey:(NSString*)key
{
  [self login];
  return nil;
}

- (NSArray*)getArchivedTasksFromDate:(NSDate*)start toDate:(NSDate*)finish
{
  [self login];
  return nil;
}

@end
