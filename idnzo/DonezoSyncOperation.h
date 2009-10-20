//
//  DonezoSyncOperation.h
//  DNZO
//
//  Created by Taylor Hughes on 10/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface DonezoSyncOperation : NSInvocationOperation {
  NSString *identifier;
}

@property (copy) NSString *identifier;

@end
