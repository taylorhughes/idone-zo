//
//  Context.m
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Context.h"

@implementation Context

@synthesize name;

- (void) dealloc
{
  [name release];
  [super dealloc];
}

@end
