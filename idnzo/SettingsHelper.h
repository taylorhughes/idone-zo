//
//  SettingsHelper.h
//  DNZO
//
//  Created by Taylor Hughes on 12/7/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "SFHFKeychainUtils.h"

@interface SettingsHelper : NSObject {
}

+ (BOOL) isSyncEnabled;
+ (NSString*) username;
+ (NSString*) password;
+ (BOOL) hasPassword;

+ (void) setIsSyncEnabled:(BOOL)enabled;
+ (void) setUsername:(NSString*)username;
+ (void) setPassword:(NSString*)username;

+ (NSString*) URL;

@end
