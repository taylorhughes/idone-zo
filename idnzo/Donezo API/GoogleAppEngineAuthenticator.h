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
  NSData *cookieData;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, copy) NSString *appDescription;
@property (nonatomic, retain) NSData *cookieData;

- (id)initForGAEAppAtUrl:(NSURL*)gaeAppURL withUsername:myUsername andPassword:(NSString*)myPassword;
- (BOOL)login;

@end
