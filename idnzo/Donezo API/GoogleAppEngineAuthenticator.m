//
//  GoogleAppEngineAuthenticator.m
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GoogleAppEngineAuthenticator.h"
@interface GoogleAppEngineAuthenticator ()

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (NSString*)getAuthToken;
- (BOOL)getAuthCookieFromToken:(NSString*)authToken;

@end

#define AUTH_URL @"https://www.google.com/accounts/ClientLogin"

@implementation GoogleAppEngineAuthenticator

@synthesize url;
@synthesize username, password;
@synthesize appDescription;
@synthesize cookieData;

- (id)initForGAEAppAtUrl:(NSURL*)gaeAppURL withUsername:myUsername andPassword:(NSString*)myPassword
{ 
  self = [super init];
  if (self != nil)
  {
    self.url = gaeAppURL;
    self.username = myUsername;
    self.password = myPassword;
  }
  return self;
}

- (BOOL)login
{
  NSString *token = [self getAuthToken];
  return [self getAuthCookieFromToken:token];
}

- (NSString *)getAuthToken
{
  NSString *myUsername = [self.username stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString *myPassword = [self.password stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString *postBody = [NSString stringWithFormat:@"accountType=%s&Email=%s&Passwd=%s&service=ah", @"GOOGLE", myUsername, myPassword];
  
  if (self.appDescription != nil)
  {
    NSString *myAppDescription = [self.appDescription stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    postBody = [postBody stringByAppendingString:[NSString stringWithFormat:@"&source=%s", myAppDescription]];
  }
  
  NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:AUTH_URL]];
  [authRequest setHTTPMethod:@"POST"];
  [authRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
  [authRequest setHTTPBody:[postBody dataUsingEncoding:NSASCIIStringEncoding]];
  
  NSHTTPURLResponse *authResponse;
  NSError *authError;
  NSData *authData = [NSURLConnection sendSynchronousRequest:authRequest returningResponse:&authResponse error:&authError];      

  NSString *authResponseBody = [[NSString alloc] initWithData:authData encoding:NSASCIIStringEncoding];

  // Loop through response body which is key=value pairs, separated by \n.
  // The code below is not optimal and certainly error prone. 
  NSArray *lines = [authResponseBody componentsSeparatedByString:@"\n"];
  NSMutableDictionary *token = [NSMutableDictionary dictionary];
  for (NSString *line in lines)
  {
    NSArray *kvpair = [line componentsSeparatedByString:@"="];
    if ([kvpair count] > 1)
    {
      [token setObject:[kvpair objectAtIndex:1] forKey:[kvpair objectAtIndex:0]];
    }
  }

  // If google returned an error in the body [google returns Error=Bad Authentication in the body. which is weird, not sure if they use status codes]
  if ([token objectForKey:@"Error"])
  {
    NSLog(@"Got an error from Google authentication: %@", [token objectForKey:@"Error"]);
    return nil;
  }
  
  return [token objectForKey:@"Auth"];
}

- (BOOL)getAuthCookieFromToken:(NSString*)authToken
{
  authToken = [authToken stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  
  NSString *authArgs = [NSString stringWithFormat:@"_ah/login?continue=%s&auth=%s", [self.url absoluteString], authToken];
  NSString *authURL = [[self.url absoluteString] stringByAppendingPathComponent:authArgs];
  
  NSLog(@"Here's the path: %s", authURL);
  
  NSHTTPURLResponse *cookieResponse;
  NSError *cookieError;
  NSMutableURLRequest *cookieRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:authURL]];
  
  [cookieRequest setHTTPMethod:@"GET"];
  
  self.cookieData = [NSURLConnection sendSynchronousRequest:cookieRequest returningResponse:&cookieResponse error:&cookieError];
  
  if (cookieError != nil)
  {
    NSLog(@"Encountered an error somehow fetching the auth cookie! %@", cookieError);
    return NO;
  }
  
  NSLog(@"Cookie data looks like this: %@", self.cookieData);
  
  [cookieRequest release];
  
  return YES;
}


@end
