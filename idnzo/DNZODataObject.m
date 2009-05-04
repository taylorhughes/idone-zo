//
//  DNZODataObject.m
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DNZODataObject.h"

static sqlite3 *db = nil;

@implementation DNZODataObject

@synthesize key, remoteKey;

+ (void) setDatabase:(sqlite3*)dbToSet {
  db = dbToSet;
}

- (void) save {
  // pass
}
- (void) destroy {
  // pass
}

@end
