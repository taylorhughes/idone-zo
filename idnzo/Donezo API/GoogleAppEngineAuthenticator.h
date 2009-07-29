//
//  GoogleAppEngineAuthenticator.h
//  DNZO
//
//  Created by Taylor Hughes on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GoogleAppEngineAuthenticator : NSObject {
  NSURL *url;
  NSString *username;
  NSString *password;
  NSString *appDescription;
  BOOL hasLoggedIn;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, copy) NSString *appDescription;
@property (nonatomic, assign) BOOL hasLoggedIn;

- (id)initForGAEAppAtUrl:(NSURL*)gaeAppURL withUsername:myUsername andPassword:(NSString*)myPassword;
- (BOOL)login:(NSError**)error;

@end
