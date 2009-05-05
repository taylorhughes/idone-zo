//
//  EditViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

@class Task;

@interface EditViewController : UIViewController <UITextFieldDelegate> {
  IBOutlet UITextField *body;
  IBOutlet UIButton *saveButton;
  IBOutlet UIButton *cancelButton;
  Task *task;
}

@property (retain, nonatomic) Task *task;
@property (retain, nonatomic) IBOutlet UITextField *body;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction) save:(id) sender;
- (IBAction) cancel:(id)sender;

@end
