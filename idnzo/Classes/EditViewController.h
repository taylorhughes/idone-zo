//
//  EditViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "TextFieldController.h"

@class Task, TextFieldController;

@interface EditViewController : UITableViewController {
  Task *task;
  TextFieldController *textFieldController;
}

@property (retain, nonatomic) Task *task;

+ (UINavigationController*) navigationControllerWithTask:(Task*)task dismissTarget:(UIViewController*)target dismissAction:(SEL)action;

@end
