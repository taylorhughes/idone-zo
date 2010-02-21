//
//  TaskCell.h
//  CustomTableViewCell
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "TaskCellView.h"
#import "Task.h"
#import "DonezoTask.h"

@class TaskCellView;

@interface TaskCell : UITableViewCell {
  TaskCellView *taskCellView;
  
  NSTimer *contentViewTransitionTimer;
  CGRect contentViewBeginFrame;
  CGRect contentViewEndFrame;
  BOOL isAboutToTransition;
  BOOL isTransitioning;
}

@property (nonatomic, retain, readonly) TaskCellView *taskCellView;

- (void) displayLocalTask:(Task*)task;
- (void) displayLocalTask:(Task*)task archived:(BOOL)isArchived;
- (void) displayRemoteTask:(DonezoTask*)task;

@end
