//
//  EditViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

@class Task;

@interface EditViewController : UITableViewController {
  Task *task;
}

@property (retain, nonatomic) Task *task;

@end
