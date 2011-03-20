// 
//  Project.m
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "Project.h"
#import "Project_Private.h"

@interface Project ()
+ (NSArray*)projects:(NSManagedObjectContext*)context;
@end

@implementation Project 

@dynamic name;
@dynamic deleted;

+ (NSArray*)projects:(NSManagedObjectContext*)context
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
  request.entity = entity;
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
  NSArray *sorters = [NSArray arrayWithObjects:sort, nil];
  request.sortDescriptors = sorters;
  [sort release];
  
  NSError *error = nil;
  NSArray *projects = [context executeFetchRequest:request error:&error];
  if (projects == nil)
  {
    // handle error
    NSLog(@"No projects! What?!");
  }

  [request release];
  return projects;
}

+ (NSArray*)projectNames:(NSManagedObjectContext*)context
{
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  for (Project *project in [self projects:context])
  {
    if (![project isDeleted])
    {
      [array addObject:project.name];
    }
  }
  return array;
}

+ (Project*)findProjectWithName:(NSString*)name inContext:(NSManagedObjectContext*)context
{
  for (Project *project in [self projects:context])
  {
    if ([project.name isEqualToString:name])
    {
      return project;
    }
  }
  return nil;
}

+ (Project*) findOrCreateProjectWithName:(NSString*)name inContext:(NSManagedObjectContext*)context
{
  name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (name == nil || [name isEqualToString:@""])
  {
    return nil;
  }
  
  Project* match = [Project findProjectWithName:name inContext:context];
  if (match == nil)
  {
    match = (Project*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:context];
    match.name = name;
  }
  return match;
}


- (NSInteger)compare:(Project*)other
{
  return [self.name compare:other.name];
}

- (BOOL)isDeleted
{
  return [self.deleted intValue];
}
- (void)setIsDeleted:(BOOL)isDeleted
{
  self.deleted = [NSNumber numberWithInt:isDeleted];
}

@end
