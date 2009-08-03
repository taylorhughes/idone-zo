//
//  DNZO.h
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GoogleAppEngineAuthenticator.h"
#import "JSON.h"
#import "DonezoTask.h"
#import "DonezoTaskList.h"
#import "NSString+Donezo.h"

@class DonezoTask;

@interface DonezoAPIClient : NSObject {
  GoogleAppEngineAuthenticator *gaeAuth;
}

@property (nonatomic, retain) GoogleAppEngineAuthenticator *gaeAuth;

- (id) initWithUsername:(NSString*)username andPassword:(NSString*)password;

- (NSArray*) getLists:(NSError**)error;
- (NSArray*) getTasksForListWithKey:(NSString*)key error:(NSError**)error;

- (void) saveTask:(DonezoTask*)task error:(NSError**)error;
- (void) deleteTask:(DonezoTask*)task error:(NSError**)error;

//- (NSArray*)getArchivedTasksFromDate:(NSDate*)start toDate:(NSDate*)finish error:(NSError**)error;

+ (NSDate*) dateFromDonezoDateString:(NSString*)stringDate;
+ (NSString*) donezoDateStringFromDate:(NSDate*)date;

@end
