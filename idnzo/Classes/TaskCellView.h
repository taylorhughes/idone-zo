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
  BOOL highlighted;
}

@property (nonatomic, retain) Task *task;
@property (nonatomic, assign) BOOL wasCompleted;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

+ (NSInteger) height;
// Indicates whether the checkbox was clicked/touched with the latest event

@end