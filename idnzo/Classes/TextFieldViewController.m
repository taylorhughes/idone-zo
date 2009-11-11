//
//  TextFieldViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 11/10/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "TextFieldViewController.h"

@implementation TextFieldViewController

@synthesize text, placeholder;

@synthesize target;
@synthesize saveAction, cancelAction;

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  UIBarButtonItem *save   = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                           target:self
                                                                           action:@selector(save:)] autorelease];
  
  UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(cancel:)] autorelease];
  
  self.navigationItem.rightBarButtonItem = save;
  self.navigationItem.leftBarButtonItem = cancel;
  
  textField.text = self.text;
  textField.placeholder = self.placeholder;
  
  self.navigationItem.title = self.title;
}

- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  [textField becomeFirstResponder];
  // Put the cursor at the end
  //textField.selectedRange = NSMakeRange(textField.text.length, 0);
}

- (void) cancel:(id)sender
{
  if (self.target && self.cancelAction)
  {
    [self.target performSelector:self.cancelAction withObject:self];
  }
  
  [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void) save:(id)sender
{
  self.text = textField.text;
  
  if (self.target && self.saveAction)
  {
    [self.target performSelector:self.saveAction withObject:self];
  }
  
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) dealloc
{
  [text dealloc];
  [placeholder dealloc];
  [textField dealloc];
  [super dealloc];
}

@end
