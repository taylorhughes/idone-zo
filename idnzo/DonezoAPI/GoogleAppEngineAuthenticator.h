//
//  GoogleAppEngineAuthenticator.h
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "NSString+Donezo.h"
#import "NSDictionary+Donezo.h"

@interface GoogleAppEngineAuthenticator : NSObject {
  NSURL *url;
  NSString *username;
  NSString *password;
  NSString *appDescription;
  NSString *continueToPath;
  BOOL hasLoggedIn;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, copy) NSString *appDescription;
@property (nonatomic, assign) BOOL hasLoggedIn;
@property (nonatomic, copy) NSString *continueToPath;

- (id)initForGAEAppAtUrl:(NSURL*)gaeAppURL withUsername:(NSString*)myUsername andPassword:(NSString*)myPassword;
- (id)initForGAEAppAtUrl:(NSURL*)gaeAppURL toPath:(NSString*)path withUsername:(NSString*)myUsername andPassword:(NSString*)myPassword;

- (BOOL)login:(NSError**)error;

@end
