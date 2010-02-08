//
//  TaskCellView.h
//  DNZO
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "Task.h"
#import "Project.h"
#import "DNZOAppDelegate.h"

@class Task, Project;

@interface TaskCellView : UIView {
  NSString *body;
  NSArray *details;
  BOOL isComplete;
  BOOL highlighted;
  BOOL archivedDisplay;
  BOOL isTouchingCheckbox;
  
  Task *task;
}

@property (nonatomic) BOOL isComplete;
@property (nonatomic, retain) NSString *body;
// An array of strings to put on the second row
@property (nonatomic, retain) NSArray *details;
@property (nonatomic, assign) BOOL archivedDisplay;

@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@property (nonatomic, retain) Task *task;

+ (NSInteger) height;

@end