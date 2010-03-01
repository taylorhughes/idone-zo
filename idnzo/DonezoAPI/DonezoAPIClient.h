//
//  DNZO.h
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "GoogleAppEngineAuthenticator.h"
#import "JSON.h"
#import "DonezoTask.h"
#import "DonezoTaskList.h"
#import "NSString+Donezo.h"
#import "DonezoDates.h"

@class DonezoTask;

@interface DonezoAPIClient : NSObject {
  GoogleAppEngineAuthenticator *gaeAuth;
  NSString *baseUrl;
}

@property (nonatomic, retain) GoogleAppEngineAuthenticator *gaeAuth;

- (id) initWithUsername:(NSString*)username andPassword:(NSString*)password;
- (id) initWithUsername:(NSString*)username andPassword:(NSString*)password toBaseUrl:(NSString*)baseURL;

- (BOOL)login:(NSError**)error;

- (NSArray*) getLists:(NSError**)error;
- (DonezoTaskList*) getListWithKey:(NSString*)key error:(NSError**)error;
- (NSArray*) getTasksForListWithKey:(NSString*)key error:(NSError**)error;

- (void) saveTask:(DonezoTask**)task taskList:(DonezoTaskList*)list error:(NSError**)error;
- (void) deleteTask:(DonezoTask**)task error:(NSError**)error;

- (void) saveList:(DonezoTaskList**)list error:(NSError**)error;
- (void) deleteList:(DonezoTaskList**)list error:(NSError**)error;

- (NSArray*) getArchivedTasksCompletedBetweenDate:(NSDate*)start andDate:(NSDate*)finish error:(NSError**)error;

@end
