//
//  TextFieldController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/6/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

@interface TextFieldController : UIViewController <UITextFieldDelegate> {
  NSString *text;
  UITextView *textView;
  NSObject *target;
  SEL saveAction;
  SEL cancelAction;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSObject *target;

@property (nonatomic) SEL saveAction;
@property (nonatomic) SEL cancelAction;

@end
