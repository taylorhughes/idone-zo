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
@end

@implementation TextViewController

@synthesize text, textView, target;
@synthesize saveAction, cancelAction;

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    self.textView = [[[UITextView alloc] init] autorelease];
    self.view = self.textView;
    
    UIBarButtonItem *save   = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(save:)] autorelease];
    
    UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(cancel:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = save;
    self.navigationItem.leftBarButtonItem = cancel;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
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

- (void)dealloc
{
  [target release];
  [text release];
  [textView release];
  [super dealloc];
}


@end