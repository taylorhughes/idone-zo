//
//  SettingsHelper.m
//  DNZO
//
//  Created by Taylor Hughes on 12/7/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "SettingsHelper.h"

#define DEFAULTS [NSUserDefaults standardUserDefaults]

#define SERVICE_NAME @"Done-zo"

#define SYNC_ENABLED_KEY @"syncEnabled"
#define USERNAME_KEY @"username"
#define SYNCED_USERNAME_KEY @"syncedUsername"
#define PASSWORD_KEY @"password"

#define FILTERED_OBJECT_KEY_FORMAT @"filteredObject-%@"
#define SORT_KEY_KEY_FORMAT @"sortKey-%@"
#define SORT_DESCENDING_FORMAT @"sortDesc-%@"

#define LAST_VIEWED_LIST_KEY @"lastViewedList"


@interface SettingsHelper (Private)

+ (NSManagedObject*) managedObjectForKey:(NSString*)key inContext:(NSManagedObjectContext*)context;
+ (void) setManagedObject:(NSManagedObject*)object forKey:(NSString*)key;

+ (NSString*) filteredObjectKeyForList:(TaskList*)list;

@end


@implementation SettingsHelper

+ (BOOL) isSyncEnabled
{
  return [DEFAULTS boolForKey:SYNC_ENABLED_KEY];
}

+ (BOOL) canSync
{
  return [self isSyncEnabled] && [self hasUsername] && [self hasPassword];
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

+ (NSString*) syncedUsername
{
  return [DEFAULTS stringForKey:SYNCED_USERNAME_KEY];
}

+ (BOOL) hasUsername
{
  NSString *user = [SettingsHelper username];
  return user != nil && [user length] > 0;
}

+ (BOOL) hasSyncedUsername
{
  NSString *user = [self syncedUsername];
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

+ (void) setSyncedUsername:(NSString*)username
{
  [DEFAULTS setValue:username forKey:SYNCED_USERNAME_KEY];
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

+ (NSManagedObject*) managedObjectForKey:(NSString*)key inContext:(NSManagedObjectContext*)context
{
  NSManagedObject *object = nil;
  NSString *filteredURI = [DEFAULTS objectForKey:key];
  if (filteredURI)
  {
    NSURL *url = [NSURL URLWithString:filteredURI];
    NSManagedObjectID *mid = [[context persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];
    object = [context objectWithID:mid];
  }
  
  return object;
}

+ (void) setManagedObject:(NSManagedObject*)object forKey:(NSString*)key
{
  NSString *objectURI = [[[object objectID] URIRepresentation] absoluteString];
  [DEFAULTS setObject:objectURI forKey:key];
}


+ (NSString*) filteredObjectKeyForList:(TaskList*)list
{
  NSString *listURI = [[[list objectID] URIRepresentation] absoluteString];
  return [NSString stringWithFormat:FILTERED_OBJECT_KEY_FORMAT, listURI];
}

+ (void) setFilteredObject:(NSObject*)object forList:(TaskList*)list
{
  NSString *key = [self filteredObjectKeyForList:list];
  
  if ([object isKindOfClass:[NSManagedObject class]])
  {
    [self setManagedObject:(NSManagedObject*)object forKey:key];
  }
  else
  {
    [DEFAULTS setObject:(NSDate*)object forKey:key];
  }
}

+ (NSObject*) filteredObjectForList:(TaskList*)list
{
  NSString *key = [self filteredObjectKeyForList:list];
  
  NSObject *object = [DEFAULTS objectForKey:key];
  
  if ([object isKindOfClass:[NSDate class]])
  {
    return object;
  }
  return [self managedObjectForKey:key inContext:[list managedObjectContext]];
}


+ (NSString*) sortKeyKeyForList:(TaskList*)list
{
  NSString *listURI = [[[list objectID] URIRepresentation] absoluteString];
  return [NSString stringWithFormat:SORT_KEY_KEY_FORMAT, listURI];
}
+ (void) setSortKey:(NSString*)sortKey forList:(TaskList*)list
{
  NSString *key = [self sortKeyKeyForList:list];
  [DEFAULTS setObject:sortKey forKey:key];
}
+ (NSString*) sortKeyForList:(TaskList*)list
{
  return [DEFAULTS objectForKey:[self sortKeyKeyForList:list]]; 
}


+ (NSString*) sortDescendingKeyForList:(TaskList*)list
{
  NSString *listURI = [[[list objectID] URIRepresentation] absoluteString];
  return [NSString stringWithFormat:SORT_DESCENDING_FORMAT, listURI];
}
+ (void) setSortDescending:(BOOL)descending forList:(TaskList*)list
{
  NSString *key = [self sortDescendingKeyForList:list];
  [DEFAULTS setBool:descending forKey:key];
}
+ (BOOL) isSortDescendingForList:(TaskList*)list
{
  return [DEFAULTS boolForKey:[self sortDescendingKeyForList:list]];
}



+ (void) setLastViewedList:(TaskList*)list
{
  [self setManagedObject:list forKey:LAST_VIEWED_LIST_KEY];
}

+ (TaskList*) lastViewedListInContext:(NSManagedObjectContext*)context
{
  return (TaskList*)[self managedObjectForKey:LAST_VIEWED_LIST_KEY inContext:context];
}



+ (NSString*) URL
{
//#if TARGET_IPHONE_SIMULATOR
//  #if true
//    return @"http://localhost:8081/";
//  #else
//    return @"http://dnzo-staging.appspot.com/";
//  #endif
//#else
  return @"https://dnzo.appspot.com/";
//#endif
}

@end
