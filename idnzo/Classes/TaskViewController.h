//
//  TaskViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "EditViewController.h"
#import "DNZOAppDelegate.h"

@class Task, EditViewController;

@interface TaskViewController : UIViewController {
  IBOutlet UIButton *deleteButton;
  IBOutlet UIButton *completeButton;
  IBOutlet UILabel *body;
  Task *task;
  
  NSManagedObjectContext *editingContext;
}

@property (nonatomic, retain) IBOutlet UIButton *deleteButton;
@property (nonatomic, retain) IBOutlet UIButton *completeButton;
@property (nonatomic, retain) IBOutlet UILabel *body;
@property (nonatomic, retain) Task *task;

- (void) refresh;
- (IBAction) complete:(id)sender;

@end
