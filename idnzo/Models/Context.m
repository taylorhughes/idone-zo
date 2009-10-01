// 
//  Context.m
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Context.h"


@implementation Context 

@dynamic name;

+ (Context*) findContextWithName:(NSString*)name inContext:(NSManagedObjectContext*)context
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:@"Context" inManagedObjectContext:context];;
  request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
  
  NSError *error = nil;  
  NSArray *result = [context executeFetchRequest:request error:&error];
  [request release];
  if ([result count] > 0)
  {
    return [result objectAtIndex:0];
  }
  return nil;
}

+ (Context*) findOrCreateContextWithName:(NSString*)name inContext:(NSManagedObjectContext*)context
{
  Context *match = [Context findContextWithName:name inContext:context];
  if (!match)
  {
    match = (Context*)[NSEntityDescription insertNewObjectForEntityForName:@"Context" inManagedObjectContext:context];
    match.name = name;
  }
  return match;
}

+ (NSArray*) findOrCreateContextsWithNames:(NSArray*)names inContext:(NSManagedObjectContext*)context
{
  NSMutableArray *contexts = [NSMutableArray arrayWithCapacity:[names count]];
  for (NSString *contextName in names)
  {
    [contexts addObject:[Context findOrCreateContextWithName:contextName inContext:context]];
  }
  return contexts;
}

+ (NSArray*)contexts:(NSManagedObjectContext*)context
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Context" inManagedObjectContext:context];
  request.entity = entity;
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
  NSArray *sorters = [NSArray arrayWithObjects:sort, nil];
  request.sortDescriptors = sorters;
  [sort release];
  
  NSError *error = nil;
  NSArray *contexts = [context executeFetchRequest:request error:&error];
  if (contexts == nil)
  {
    // handle error
    NSLog(@"No contexts! What?!");
  }
  
  [request release];
  return contexts;
}

+ (NSArray*)contextNames:(NSManagedObjectContext*)inContext
{
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  for (Context *context in [self contexts:inContext])
  {
    [array addObject:[NSString stringWithFormat:@"@%@", context.name]];
  }
  return array;
}

@end
