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
  NSString *format = @"%b %e";
  // See if the years are the same. Is there an easier way?
  if (![[   [NSDate date] descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:nil] 
        isEqual:[self.due descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:nil]])
  {
    format = [format stringByAppendingString:@" %y"];
  }
  return [self.due descriptionWithCalendarFormat:format timeZone:nil locale:nil];
}

@end
