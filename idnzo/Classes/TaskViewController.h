//
//  TaskViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "Task.h"
#import "TaskList.h"
#import "DNZOAppDelegate.h"
#import "EditProjectPicker.h"
#import "DatePickerViewController.h"
#import "TextViewController.h"
#import "AdjustableTextLabelWidthCell.h"
#import "ConfirmationViewController.h"

@class Task;

@interface TaskViewController : UITableViewController {
 @private
  Task *task;
  NSManagedObjectContext *editingContext;
  BOOL isEditing;
  
  IBOutlet UIView *bodyView;
  IBOutlet UIView *bodyEditView;
  IBOutlet UIView *bottomView;
  
  IBOutlet UILabel *topLabel;
  IBOutlet UIButton *topCheckmark;
  IBOutlet UIButton *topButton;
  
  BOOL isNewTask;
  BOOL isFirstAppearance;
  
  ConfirmationViewController *confirm;
}

- (void) loadTask:(Task*)newTask editing:(BOOL)editing positionInList:(NSInteger)position ofTotalCount:(NSInteger)total;
- (void) loadEditingWithNewTaskForList:(TaskList*)list;

- (IBAction) askToDeleteTask:(id)sender;

@property (nonatomic, readonly) BOOL isEditing;

@end
