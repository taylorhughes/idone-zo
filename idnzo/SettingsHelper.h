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
+ (NSString*) syncedUsername;
+ (BOOL) hasUsername;
+ (BOOL) hasSyncedUsername;
+ (NSString*) password;
+ (BOOL) hasPassword;

+ (void) setIsSyncEnabled:(BOOL)enabled;
+ (void) setUsername:(NSString*)username;
+ (void) setSyncedUsername:(NSString*)username;
+ (void) setPassword:(NSString*)username;
+ (void) resetPassword;

+ (void) setLastViewedList:(TaskList*)list;
+ (TaskList*) lastViewedListInContext:(NSManagedObjectContext*)context;

+ (void) setFilteredObject:(NSObject*)object forList:(TaskList*)list;
+ (NSObject*) filteredObjectForList:(TaskList*)list;

+ (void) setSortKey:(NSString*)sortKey forList:(TaskList*)list;
+ (NSString*) sortKeyForList:(TaskList*)list;

+ (void) setSortDescending:(BOOL)descending forList:(TaskList*)list;
+ (BOOL) isSortDescendingForList:(TaskList*)list;

+ (NSString*) URL;

@end
