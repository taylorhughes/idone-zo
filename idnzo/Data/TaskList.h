//
//  TaskList.h
//  DNZO
//
//  Created by Taylor Hughes on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SQLitePersistentObject.h"

@interface TaskList : SQLitePersistentObject {
  NSString *name;
}

@property (copy, nonatomic) NSString *name;

@end
