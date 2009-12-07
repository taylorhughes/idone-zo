//
//  TextFieldViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 11/10/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

//
//  TextFieldViewController -- This is a controller for a view containing
//    only a single UITextField, which is a text box.
//  
@interface TextFieldViewController : UIViewController {
  IBOutlet UITextField *textField;
  NSString *text;
  NSString *placeholder;
  NSObject *target;
  SEL saveAction;
  SEL cancelAction;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) NSObject *target;

@property (nonatomic, readonly) UITextField *textField;

@property (nonatomic) SEL saveAction;
@property (nonatomic) SEL cancelAction;

@end
