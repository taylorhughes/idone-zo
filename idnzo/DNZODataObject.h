//
//  DNZODataObject.h
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

@interface DNZODataObject : NSObject {
  
  NSInteger key;
  NSString *remoteKey;
  
}

// Local database key
@property (assign, nonatomic, readonly) NSInteger key;
// Remote key, if applicable
@property (copy, nonatomic) NSString *remoteKey;

// Static members
+ (void) setDatabase:(sqlite3 *)db;

// Instance members
- (void) save;
- (void) destroy;

@end
