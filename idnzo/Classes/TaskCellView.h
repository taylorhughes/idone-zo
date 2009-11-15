//
//  TaskCellView.h
//  DNZO
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "Task.h"
#import "Project.h"

@class Task, Project;

@interface TaskCellView : UIView {
  NSString *body;
  NSArray *details;
  BOOL isComplete;
  BOOL wasCompleted;
  BOOL highlighted;
  BOOL archivedDisplay;
}

@property (nonatomic) BOOL isComplete;
@property (nonatomic, retain) NSString *body;
// An array of strings to put on the second row
@property (nonatomic, retain) NSArray *details;
@property (nonatomic, assign) BOOL archivedDisplay;

// Indicates whether the checkbox was clicked/touched with the latest event
@property (nonatomic, assign) BOOL wasCompleted;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

+ (NSInteger) height;

@end