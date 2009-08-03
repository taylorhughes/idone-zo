//
//  NSString+Donezo.m
//  DNZO
//
//  Created by Taylor Hughes on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+Donezo.h"

@implementation NSString (Donezo)

- (NSString*)urlencoded
{
  NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
  return [result autorelease];
}

@end
