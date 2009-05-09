//
//  TextFieldController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TextFieldController.h"

@interface TextFieldController ()
- (void) save:(id)sender;
- (void) cancel:(id)sender;
- (void) refresh;
- (void) finish;
@end

@implementation TextFieldController

@synthesize text, textView, target, saveAction;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UIBarButtonItem *save = [[[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                             target:self action:@selector(save:)] autorelease];
  UIBarButtonItem *cancel = [[[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                               target:self action:@selector(cancel:)] autorelease];
  
  self.navigationItem.rightBarButtonItem = save;
  self.navigationItem.leftBarButtonItem = cancel;
  
  self.textView.text = self.text;
  
  [textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
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
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
  [target release];
  [text release];
  [textView release];
  [super dealloc];
}


@end
