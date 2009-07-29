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

- (BOOL)isProductionURL;
- (NSString*)getAuthToken:(NSError**)error;
- (BOOL)getAuthCookieWithToken:(NSString*)authToken error:(NSError**)error;

+ (NSString*)urlEncode:(NSString*)string;

@end

#define AUTH_URL @"https://www.google.com/accounts/ClientLogin"

@implementation GoogleAppEngineAuthenticator

@synthesize url;
@synthesize username, password;
@synthesize appDescription;
@synthesize hasLoggedIn;

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
  NSString *myUsername = [GoogleAppEngineAuthenticator urlEncode:self.username];
  NSString *myPassword = [GoogleAppEngineAuthenticator urlEncode:self.password];
  NSString *postBody = [NSString stringWithFormat:@"accountType=%@&Email=%@&Passwd=%@&service=ah", @"GOOGLE", myUsername, myPassword];
  
  if (self.appDescription != nil)
  {
    NSString *myAppDescription = [GoogleAppEngineAuthenticator urlEncode:self.appDescription];
    postBody = [postBody stringByAppendingString:[NSString stringWithFormat:@"&source=%@", myAppDescription]];
  }
  
  //NSLog(@"Here's the post body: %@", postBody);
  
  NSURL *authURL = [NSURL URLWithString:AUTH_URL];
  NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:authURL];
  [authRequest setHTTPMethod:@"POST"];
  [authRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
  [authRequest setHTTPBody:[postBody dataUsingEncoding:NSASCIIStringEncoding]];
  
  NSHTTPURLResponse *authResponse;
  NSError *authError = nil;
  NSData *authData = [NSURLConnection sendSynchronousRequest:authRequest returningResponse:&authResponse error:&authError];      

  if (authError != nil)
  {
    //NSLog(@"Oh no, an error for request to %@: %@", [authURL description], [authError description]);
    *error = authError;
    return nil;
  }
  
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
  NSString *authArgs = [NSString stringWithFormat:@"?continue=%@", [GoogleAppEngineAuthenticator urlEncode:[self.url absoluteString]]];
  
  if (authToken != nil)
  {
    //NSLog(@"Appending auth token %@ ...", authToken);
    authToken = [GoogleAppEngineAuthenticator urlEncode:authToken];
    authArgs = [authArgs stringByAppendingString:[NSString stringWithFormat:@"&auth=%@", authToken]];
  }
  else
  {
    NSString *encodedUser = [GoogleAppEngineAuthenticator urlEncode:self.username];
    authArgs = [authArgs stringByAppendingString:[NSString stringWithFormat:@"&email=%@", encodedUser]];
  }
  
  NSString *authURL = [[self.url absoluteString] stringByAppendingPathComponent:@"_ah/login"];
  authURL = [authURL stringByAppendingString:authArgs];
  
  //NSLog(@"Here's the path: %@", authURL);
  
  NSHTTPURLResponse *cookieResponse;
  NSError *cookieError;
  NSMutableURLRequest *cookieRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:authURL]];
  
  [cookieRequest setHTTPMethod:@"GET"];
  
  //NSData *cookieData = 
  [NSURLConnection sendSynchronousRequest:cookieRequest returningResponse:&cookieResponse error:&cookieError];
  
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

+ (NSString *)urlEncode:(NSString *)string
{
  NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
  return [result autorelease];
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
