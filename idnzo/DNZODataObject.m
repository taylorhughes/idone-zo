//
//  DNZODataObject.m
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DNZODataObject.h"

static sqlite3 *database = nil;

@implementation DNZODataObject

@synthesize key, remoteKey;

+ (void) setDatabase:(sqlite3*)dbToSet {
  database = dbToSet;
}

+ (sqlite3 *) database {
  return database;
}

- (void) save {
  // pass
}
- (void) destroy {
  // pass
}

@end
