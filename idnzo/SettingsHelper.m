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

@implementation SettingsHelper

+ (BOOL) isSyncEnabled
{
  return [DEFAULTS boolForKey:SYNC_ENABLED_KEY];
}

+ (NSString*) password
{
  return [DEFAULTS stringForKey:PASSWORD_KEY];
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

+ (void) setIsSyncEnabled:(BOOL)enabled
{
  [DEFAULTS setBool:enabled forKey:SYNC_ENABLED_KEY];
}

+ (void) setUsername:(NSString*)username
{
  [DEFAULTS setValue:username forKey:USERNAME_KEY];
}

+ (void) setPassword:(NSString*)username
{
  [DEFAULTS setValue:username forKey:PASSWORD_KEY];
}

@end
