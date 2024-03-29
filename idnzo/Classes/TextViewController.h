//
//  TextViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 5/6/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

//
//  TextViewController -- This is a controller for a view entirely consumed
//    by a central UITextView, which takes up the whole screen and offers a
//    keyboard when shown.
//  
@interface TextViewController : UIViewController <UITextViewDelegate> {
  NSString *text;
  UITextView *textView;
  NSObject *target;
  SEL saveAction;
  SEL cancelAction;
  BOOL keyboardShown;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSObject *target;

@property (nonatomic) SEL saveAction;
@property (nonatomic) SEL cancelAction;

@end
