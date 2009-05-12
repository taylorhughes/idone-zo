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

@interface EditViewController : UITableViewController {
  Task *task;
  TextFieldController *textFieldController;
  
  NSObject *dismissTarget;
  SEL dismissAction;
  
  NSString *body;
  Project  *project;
  NSArray  *contexts;
  NSDate   *due;
}

@property (retain, nonatomic) Task *task;

@property (copy, nonatomic) NSString  *body;
@property (retain, nonatomic) Project   *project;
@property (retain, nonatomic) NSArray *contexts;
@property (copy, nonatomic) NSDate    *due;

+ (UINavigationController*) navigationControllerWithTask:(Task*)task dismissTarget:(UIViewController*)target dismissAction:(SEL)action;
+ (UINavigationController*) navigationControllerWithTask:(Task*)task;

@end
