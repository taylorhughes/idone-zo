//
//  TaskViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "DNZOAppDelegate.h"
#import "EditProjectPicker.h"

@class Task;

@interface TaskViewController : UITableViewController {
 @private
  Task *task;
  Task *uneditedTask;
  NSManagedObjectContext *editingContext;
  BOOL isEditing;
  UILabel *topLabel;
  UIImageView *topCheckmark;
}

- (void) loadTask:(Task*)newTask editing:(BOOL)editing;

@property (nonatomic, readonly) BOOL isEditing;

@end
