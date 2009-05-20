//
//  TaskCellView.h
//  DNZO
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "Project.h"

@class Task, Project;

@interface TaskCellView : UIView {
  Task *task;
  BOOL wasCompleted;
}

@property (nonatomic, retain) Task *task;
@property (nonatomic, assign) BOOL wasCompleted;

+ (NSInteger) height;
// Indicates whether the checkbox was clicked/touched with the latest event

@end