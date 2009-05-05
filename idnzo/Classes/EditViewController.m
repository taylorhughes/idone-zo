//
//  EditViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"

@implementation EditViewController

@synthesize task;
@synthesize body, saveButton, cancelButton;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.body.text = self.task.body;
}

- (void)dealloc {
  [task release];
  [super dealloc];
}

- (IBAction) save:(id)sender {
  self.task.body = self.body.text;
  [self.task save];
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) cancel:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField endEditing:YES];
  return YES;
}


@end
