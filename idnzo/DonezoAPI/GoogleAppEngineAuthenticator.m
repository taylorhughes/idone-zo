//
//  GoogleAppEngineAuthenticator.m
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#include "GoogleAppEngineAuthenticator.h"

// Removes the compiler warning for the private API call 
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

#define AUTH_URL @"https://www.google.com/accounts/ClientLogin"
#ifndef USER_AGENT_STRING
#define USER_AGENT_STRING @"GoogleAppEngineAuthenticator (unknown client)"
#endif

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
  NSString *trimmed = [self.username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (!self.username || [trimmed isEqualToString:@""])
  {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    NSString *errorString = @"Failed to login to Google Accounts because the username is blank.";
    
    [errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"DonezoAPI" code:100 userInfo:errorDetail];
    
    return nil;
  }
  
  NSMutableDictionary *postBody = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"GOOGLE", @"accountType",
                                   @"ah", @"service",
                                   self.username, @"Email",
                                   self.password, @"Passwd",
                                   nil];
  
  if (self.appDescription != nil)
  {
    [postBody setValue:self.appDescription forKey:@"source"];
  }
  
  NSURL *authURL = [NSURL URLWithString:AUTH_URL];
  NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:authURL];
  [authRequest setValue:USER_AGENT_STRING forHTTPHeaderField:@"User-Agent"];
  [authRequest setHTTPMethod:@"POST"];
  [authRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
  [authRequest setHTTPBody:[[postBody toFormEncodedString] dataUsingEncoding:NSUTF8StringEncoding]];

#if TARGET_IPHONE_SIMULATOR
  NSLog(@"Accepting all HTTPS certificates for this session.");
  // This is a private API call. In some environments, NSURLRequest may 
  // not have access to the proper set of acceptable HTTPS certificates,
  // and NSURLRequests will fail erroneously (eg. in unit tests).
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
    NSString *errorString;
    if ([responseError isEqual:@"BadAuthentication"])
    {
      errorString = @"Failed to login to Google Accounts; the username or password appears to be incorrect.";
    }
    else if ([responseError isEqual:@"CaptchaRequired"])
    {
      errorString = @"Failed to login to Google Accounts; there have been too many failed login attempts. "
                     "Log into your Google Account in a web browser, then try again.";
    }
    else
    {
      errorString = [NSString stringWithFormat:@"Failed to login to Google Accounts due to an unrecognized error. (%@)", responseError];
    }

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
    [authArgs setValue:authToken forKey:@"auth"];
  }
  else
  {
    [authArgs setValue:@"Login" forKey:@"action"];
    [authArgs setValue:self.username forKey:@"email"];
  }
  
  NSString *authURL = [[self.url absoluteString] stringByAppendingPathComponent:@"_ah/login"];
  authURL = [authURL stringByAppendingFormat:@"?%@", [authArgs toFormEncodedString]];
  
  NSError *cookieError;
  NSMutableURLRequest *cookieRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:authURL]];
  
  [cookieRequest setHTTPMethod:@"GET"];
  [cookieRequest setValue:USER_AGENT_STRING forHTTPHeaderField:@"User-Agent"];
  
  [NSURLConnection sendSynchronousRequest:cookieRequest returningResponse:nil error:&cookieError];
  [cookieRequest release];
  
  if (cookieError != nil)
  {
    NSLog(@"Encountered an error somehow fetching the auth cookie! %@", cookieError);
    *error = cookieError;
    return NO;
  }
  
  return YES;
}

- (BOOL) isProductionURL
{
  int port = [[self.url port] intValue];
  switch(port)
  {
    case 443:
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
  [continueToPath release];
  [appDescription release];
  
  [super dealloc];
}


@end
