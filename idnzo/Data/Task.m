//
//  Task.m
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

@implementation Task

@synthesize taskList;
@synthesize body, contexts, project, due;

- (void)dealloc
{
  [taskList release];
  
  [body release];
  [contexts release];
  [project release];
  [due release];
  
  [super dealloc];
}

- (NSString *)contextsString
{
  if (!self.contexts || [self.contexts count] == 0)
  {
    return nil;
  }
  return [@"@" stringByAppendingString:[self.contexts componentsJoinedByString:@" @"]];
}

- (NSString *)dueString
{
  return [self.due descriptionWithCalendarFormat:@"%d/%m/%Y" timeZone:nil locale:nil];
}

@end
