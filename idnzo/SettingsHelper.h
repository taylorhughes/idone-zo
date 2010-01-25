//
//  SettingsHelper.h
//  DNZO
//
//  Created by Taylor Hughes on 12/7/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "SFHFKeychainUtils.h"
#import "TaskList.h"

@interface SettingsHelper : NSObject {
}

+ (BOOL) isSyncEnabled;
+ (NSString*) username;
+ (BOOL) hasUsername;
+ (NSString*) password;
+ (BOOL) hasPassword;

+ (void) setIsSyncEnabled:(BOOL)enabled;
+ (void) setUsername:(NSString*)username;
+ (void) setPassword:(NSString*)username;
+ (void) resetPassword;

+ (void) setLastViewedList:(TaskList*)list;
+ (TaskList*) lastViewedListInContext:(NSManagedObjectContext*)context;

+ (void) setFilteredObject:(NSManagedObject*)object forList:(TaskList*)list;
+ (NSManagedObject*) filteredObjectForList:(TaskList*)list;

+ (NSString*) URL;

@end
