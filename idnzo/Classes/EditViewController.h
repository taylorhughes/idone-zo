//
//  EditViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "TextFieldController.h"
#import "Project.h"
#import "EditProjectPicker.h"

@class Task, TextFieldController, Project, EditProjectPicker;

@interface EditViewController : UITableViewController <UITextViewDelegate> {
  Task *task;
  TextFieldController *textFieldController;
  
  NSObject *dismissTarget;
  SEL saveAction;
  SEL cancelAction;
}

@property (retain, nonatomic) Task *task;

+ (UINavigationController*) navigationControllerWithTask:(Task*)task dismissTarget:(UIViewController*)target saveAction:(SEL)saveAction cancelAction:(SEL)cancelAction;
+ (UINavigationController*) navigationControllerWithTask:(Task*)task;

@end
