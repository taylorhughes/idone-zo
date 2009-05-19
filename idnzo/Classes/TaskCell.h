//
//  TaskCell.h
//  CustomTableViewCell
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "TaskCellView.h"

@class Task, TaskCellView;

@interface TaskCell : UITableViewCell {
  Task *task;
  TaskCellView *taskCellView;
}

@property (nonatomic, retain) Task *task;

@end
