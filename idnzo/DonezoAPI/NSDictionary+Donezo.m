//
//  NSDictionary+Donezo.m
//  DNZO
//
//  Created by Taylor Hughes on 8/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Donezo.h"

@implementation NSDictionary (Donezo)

- (NSString*) toFormEncodedString
{  
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  
  for (NSObject *key in self)
  {
    NSObject *object = [self objectForKey:key];
    NSString *value = @"";
    if (object && ![object isKindOfClass:[NSNull class]])
    {
      value = [object description];
    }
    [array addObject:[NSString stringWithFormat:@"%@=%@", [[key description] urlencoded], [value urlencoded]]];
  }
  
  return [array componentsJoinedByString:@"&"];
}

@end
