//
//  Project.h
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SQLitePersistentObject.h"

@interface Project : SQLitePersistentObject {
  NSString *name;
}

+ (NSArray *) projectNames;
+ (Project *) findProjectWithName:(NSString *)name;

@property (copy, nonatomic) NSString *name;

@end
