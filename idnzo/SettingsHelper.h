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
+ (BOOL) hasPassword;
+ (NSString*) username;

+ (void) setIsSyncEnabled:(BOOL)enabled;
+ (void) setUsername:(NSString*)username;
+ (void) setPassword:(NSString*)username;

@end
