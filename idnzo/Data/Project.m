//
//  Project.m
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Project.h"
#import <sqlite3.h>

@implementation Project

@synthesize name;

+ (NSArray *) projectNames
{
  NSArray *projects = [Project allObjects];
  NSMutableArray *names = [[[NSMutableArray alloc] initWithCapacity:projects.count] autorelease];
  
  for (Project *project in projects)
  {
    [names addObject:project.name];
  }
  
  return names;
}

+ (Project *) findProjectWithName:(NSString *)name
{
  // Quotes the string using sqlite3_mprintf
  name = [NSString stringWithUTF8String:sqlite3_mprintf("%Q", [name UTF8String])];
  return (Project*)[Project findFirstByCriteria:@"WHERE name=%@", name];
}

- (void) dealloc
{
  [name release];
  [super dealloc];
}

@end
