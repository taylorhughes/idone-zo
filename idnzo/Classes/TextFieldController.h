//
//  TextFieldController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@interface TextFieldController : UIViewController <UITextFieldDelegate> {
  NSString *text;
  UITextView *textView;
  NSObject *target;
  SEL saveAction;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSObject *target;
@property (nonatomic) SEL saveAction;

@end
