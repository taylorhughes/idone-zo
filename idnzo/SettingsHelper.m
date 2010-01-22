//
//  SettingsHelper.m
//  DNZO
//
//  Created by Taylor Hughes on 12/7/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "SettingsHelper.h"

#define DEFAULTS [NSUserDefaults standardUserDefaults]

#define SYNC_ENABLED_KEY @"syncEnabled"
#define USERNAME_KEY @"username"
#define PASSWORD_KEY @"password"

#define SERVICE_NAME @"Done-zo"


@implementation SettingsHelper

+ (BOOL) isSyncEnabled
{
  return [DEFAULTS boolForKey:SYNC_ENABLED_KEY];
}

+ (NSString*) password
{
  NSError *error = nil;
  NSString *pass = [SFHFKeychainUtils getPasswordForUsername:USERNAME_KEY andServiceName:SERVICE_NAME error:&error];
  
  if (error != nil)
  {
    NSLog(@"Error fetching password from keychain: %@ (%@)", error, [error userInfo]);
  }
  
  return pass;
}

+ (BOOL) hasPassword
{
  NSString *pass = [SettingsHelper password];
  return pass != nil && [pass length] > 0;
}

+ (NSString*) username
{
  return [DEFAULTS stringForKey:USERNAME_KEY];
}

+ (BOOL) hasUsername
{
  NSString *user = [SettingsHelper username];
  return user != nil && [user length] > 0;
}

+ (void) setIsSyncEnabled:(BOOL)enabled
{
  [DEFAULTS setBool:enabled forKey:SYNC_ENABLED_KEY];
}

+ (void) setUsername:(NSString*)username
{
  [DEFAULTS setValue:username forKey:USERNAME_KEY];
}

+ (void) setPassword:(NSString*)password
{
  NSError *error = nil;
  [SFHFKeychainUtils storeUsername:USERNAME_KEY 
                       andPassword:password
                    forServiceName:SERVICE_NAME 
                    updateExisting:YES
                             error:&error];
  
  if (error != nil)
  {
    NSLog(@"Error saving password! %@ (%@)", error, [error userInfo]);
  }
}

+ (void) resetPassword
{
  NSError *error = nil;
  
  [SFHFKeychainUtils deleteItemForUsername:USERNAME_KEY 
                            andServiceName:SERVICE_NAME
                                     error:&error];
  
  if (error != nil)
  {
    NSLog(@"Error saving password! %@ (%@)", error, [error userInfo]);
  }
}

+ (NSString*) URL
{
#if TARGET_IPHONE_SIMULATOR
  #if true
    return @"http://localhost:8081/";
  #else
    return @"http://dnzo-staging.appspot.com/";
  #endif
#else
  return @"https://dnzo.appspot.com/";
#endif
}

@end
