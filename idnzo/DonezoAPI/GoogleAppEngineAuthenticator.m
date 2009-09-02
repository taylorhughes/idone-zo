//
//  GoogleAppEngineAuthenticator.m
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "GoogleAppEngineAuthenticator.h"

@interface NSURLRequest (Private)
+ setAllowsAnyHTTPSCertificate:(BOOL)yesOrNo forHost:(NSString*)host;
@end

@interface GoogleAppEngineAuthenticator ()

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (BOOL)isProductionURL;
- (NSString*)getAuthToken:(NSError**)error;
- (BOOL)getAuthCookieWithToken:(NSString*)authToken error:(NSError**)error;

@end

#define AUTH_URL @"https://google.com/accounts/ClientLogin"

@implementation GoogleAppEngineAuthenticator

@synthesize url;
@synthesize username, password;
@synthesize continueToPath;

@synthesize appDescription;
@synthesize hasLoggedIn;

- (id)initForGAEAppAtUrl:(NSURL*)gaeAppURL toPath:(NSString*)path withUsername:(NSString*)myUsername andPassword:(NSString*)myPassword
{
  self = [super init];
  if (self != nil)
  {
    self.url = gaeAppURL;
    self.username = myUsername;
    self.password = myPassword;
    self.continueToPath = path;
  }
  return self;
}

- (id)initForGAEAppAtUrl:(NSURL*)gaeAppURL withUsername:myUsername andPassword:(NSString*)myPassword
{
  return [self initForGAEAppAtUrl:gaeAppURL toPath:@"/" withUsername:myUsername andPassword:myPassword];
}

- (BOOL)login:(NSError**)error
{
  if ([self isProductionURL])
  {
    NSString *token = [self getAuthToken:error];
    self.hasLoggedIn = (token != nil) && [self getAuthCookieWithToken:token error:error];
  }
  else
  {
    self.hasLoggedIn = [self getAuthCookieWithToken:nil error:error];
  }
  return self.hasLoggedIn;
}

- (NSString *)getAuthToken:(NSError**)error
{
  NSMutableDictionary *postBody = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"GOOGLE", @"accountType",
                                   self.username, @"Email",
                                   self.password, @"Passwd",
                                   @"ah", @"service",
                                   nil];
  
  if (self.appDescription != nil)
  {
    [postBody setValue:self.appDescription forKey:@"source"];
  }
  
  //NSLog(@"Here's the post body: %@", postBody);
  
  NSURL *authURL = [NSURL URLWithString:AUTH_URL];
  NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:authURL];
  [authRequest setHTTPMethod:@"POST"];
  [authRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
  [authRequest setHTTPBody:[[postBody toFormEncodedString] dataUsingEncoding:NSUTF8StringEncoding]];

#if TARGET_IPHONE_SIMULATOR
  // There is apparently no other way to do this.
  [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[authURL host]];
#endif
  
  NSHTTPURLResponse *authResponse;
  NSError *authError = nil;
  NSData *authData = [NSURLConnection sendSynchronousRequest:authRequest returningResponse:&authResponse error:&authError];      

  [authRequest release];
  
  if (authError != nil)
  {
    NSLog(@"Oh no, an error for request: %@; %@", [authError description], [authError userInfo]);
    *error = authError;
    return nil;
  }
  
  NSString *authResponseBody = [[NSString alloc] initWithData:authData encoding:NSASCIIStringEncoding];
  // Loop through response body which is key=value pairs, separated by \n.
  // The code below is not optimal and certainly error prone. 
  NSArray *lines = [authResponseBody componentsSeparatedByString:@"\n"];
  [authResponseBody release];
  
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
  NSObject *responseError = [token objectForKey:@"Error"];
  if (responseError != nil)
  {
    NSLog(@"Got an error from Google authentication: %@", responseError);
    
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    NSString *errorString = [NSString stringWithFormat:@"Failed to login to Google Accounts with error: %@", responseError];
    [errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"DonezoAPI" code:100 userInfo:errorDetail];
    
    return nil;
  }
  
  return [token objectForKey:@"Auth"];
}

- (BOOL)getAuthCookieWithToken:(NSString*)authToken error:(NSError**)error
{
  NSString *continueUrl = [[self.url absoluteString] stringByAppendingPathComponent:self.continueToPath];
  NSMutableDictionary *authArgs = [NSMutableDictionary dictionaryWithObject:continueUrl forKey:@"continue"];
  
  if (authToken != nil)
  {
    //NSLog(@"Appending auth token %@ ...", authToken);
    [authArgs setValue:authToken forKey:@"auth"];
  }
  else
  {
    [authArgs setValue:@"Login" forKey:@"action"];
    [authArgs setValue:self.username forKey:@"email"];
  }
  
  NSString *authURL = [[self.url absoluteString] stringByAppendingPathComponent:@"_ah/login"];
  authURL = [authURL stringByAppendingFormat:@"?%@", [authArgs toFormEncodedString]];
  
  //NSLog(@"Here's the path: %@", authURL);
  
  //NSHTTPURLResponse *cookieResponse;
  NSError *cookieError;
  NSMutableURLRequest *cookieRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:authURL]];
  
  [cookieRequest setHTTPMethod:@"GET"];
  
  //NSData *cookieData = 
  [NSURLConnection sendSynchronousRequest:cookieRequest returningResponse:nil error:&cookieError];
  
  if (cookieError != nil)
  {
    NSLog(@"Encountered an error somehow fetching the auth cookie! %@", cookieError);
    *error = cookieError;
    return NO;
  }
  
  [cookieRequest release];
  
  return YES;
}

- (BOOL) isProductionURL
{
  int port = [[self.url port] intValue];
  switch(port)
  {
    case 80:
    case 0:
      return YES;
  }
  return NO;
}

- (void) dealloc
{
  [url release];
  [username release];
  [password release];
  
  [appDescription release];
  
  [super dealloc];
}


@end
