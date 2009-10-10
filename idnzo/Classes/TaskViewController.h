//
//  TaskViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "TaskList.h"
#import "DNZOAppDelegate.h"
#import "EditProjectPicker.h"
#import "DatePickerViewController.h"
#import "TextFieldController.h"

@class Task;

@interface TaskViewController : UITableViewController {
 @private
  Task *task;
  NSManagedObjectContext *editingContext;
  BOOL isEditing;
  
  IBOutlet UIView *bodyView;
  IBOutlet UIView *bodyEditView;
  IBOutlet UIView *bottomView;
  
  UIView *bgview;
  IBOutlet UIView *confirmationView;
  
  IBOutlet UILabel *topLabel;
  IBOutlet UIButton *topCheckmark;
  IBOutlet UIButton *topButton;
  
  BOOL isNewTask;
}

- (void) loadTask:(Task*)newTask editing:(BOOL)editing;
- (void) loadEditingWithNewTaskForList:(TaskList*)list;

- (IBAction) askToDeleteTask:(id)sender;
- (IBAction) deleteTask:(id)sender;
- (IBAction) cancelDeleteTask:(id)sender;

@property (nonatomic, readonly) BOOL isEditing;

@end
