//
//  DNZO.h
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleAppEngineAuthenticator.h"

@interface DonezoAPIClient : NSObject {
  GoogleAppEngineAuthenticator *gaeAuth;
}

@property (nonatomic, retain) GoogleAppEngineAuthenticator *gaeAuth;

- (id)initWithUsername:(NSString*)username andPassword:(NSString*)password;

- (NSArray*)getLists;
- (NSArray*)getTasksForListWithKey:(NSString*)key;

// - (NSString*)createTask:(NSDictionary*)dictionary;
// - (BOOL)updateTask:(NSString*)taskId withDictionary:(NSDictionary*)dictionary;
// - (BOOL)deleteTask:(NSString*)taskId;

- (NSArray*)getArchivedTasksFromDate:(NSDate*)start toDate:(NSDate*)finish;

@end
