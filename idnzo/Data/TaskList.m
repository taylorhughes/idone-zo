//
//  TaskList.m
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskList.h"

@implementation TaskList

@synthesize name;

- (void) dealloc
{
  [name dealloc];
  [super dealloc];
}

@end
