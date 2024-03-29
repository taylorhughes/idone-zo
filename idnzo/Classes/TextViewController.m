//
//  TextViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/6/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "TextViewController.h"

@interface TextViewController ()

- (void) save:(id)sender;
- (void) cancel:(id)sender;

- (void)registerForKeyboardNotifications;

@end

@implementation TextViewController

@synthesize text, textView, target;
@synthesize saveAction, cancelAction;

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    self.textView = [[UITextView alloc] init];
    [self.textView release];
    
    self.view = [[UIView alloc] init];
    [self.view release];
    
    [self.view addSubview:self.textView];
    
    self.textView.delegate = self;
    
    UIBarButtonItem *save   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                            target:self
                                                                            action:@selector(save:)];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = save;
    self.navigationItem.leftBarButtonItem = cancel;

    [save release];
    [cancel release];
    
    keyboardShown = NO;
    
    [self registerForKeyboardNotifications];
  }
  return self;
}

- (void)registerForKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasShown:)
                                               name:UIKeyboardDidShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasHidden:)
                                               name:UIKeyboardDidHideNotification
                                             object:nil];
}

- (void)keyboardWasShown:(NSNotification*)notification
{
  if (keyboardShown) return;
  
  NSDictionary* info = [notification userInfo];
  
  NSValue* value = [info objectForKey:UIKeyboardBoundsUserInfoKey];
  CGSize keyboardSize = [value CGRectValue].size;
  
  CGRect viewFrame = [self.textView frame];
  viewFrame.size.height -= keyboardSize.height;
  self.textView.frame = viewFrame;
  
  keyboardShown = YES;
}


// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)notification
{
  NSDictionary* info = [notification userInfo];
  
  NSValue* value = [info objectForKey:UIKeyboardBoundsUserInfoKey];
  CGSize keyboardSize = [value CGRectValue].size;
  
  CGRect viewFrame = [self.textView frame];
  viewFrame.size.height += keyboardSize.height;
  self.textView.frame = viewFrame;
  
  keyboardShown = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.textView.frame = self.view.frame;
  self.textView.text = self.text;
  
  self.navigationItem.title = self.title;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
    
  [textView becomeFirstResponder];
  // Put the cursor at the end
  textView.selectedRange = NSMakeRange(textView.text.length, 0);
}

- (void)save:(id)sender
{
  self.text = textView.text;
  
  if (target && saveAction)
  {
    [target performSelector:saveAction withObject:self];
  }
}

- (void)cancel:(id)sender
{
  if (target && cancelAction)
  {
    [target performSelector:cancelAction withObject:self];
  }
}

- (BOOL)textView:(UITextView *)tv shouldChangeTextInRange:(NSRange)original replacementText:(NSString *)replacement
{
  // If a newline is found, do not allow the change
  if ([replacement rangeOfString:@"\n"].location != NSNotFound)
  {
    return NO;
  }
  
         // Deleting text, so that's always OK
  return (original.length >= replacement.length) ||
         // ... or if the new lenght is less than the max length
         (tv.text.length + original.length < DONEZO_MAX_TASK_BODY_LENGTH);
}



- (void)dealloc
{
  [target release];
  [text release];
  [textView release];
  [super dealloc];
}


@end
