//
//  TaskViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"

@implementation TaskViewController

@synthesize completeButton, deleteButton, body, task;

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIBarButtonItem *edit = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                         target:self
                                                                         action:@selector(edit:)] autorelease];
  self.navigationItem.rightBarButtonItem = edit;
  
  [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self refresh];
}

// I don't think this has any effect.
#define MAX_BODY_HEIGHT 100

- (void)refresh
{
  self.body.text = self.task.body;
  if (self.task.complete)
  {
    [self.completeButton setTitle:@"Uncomplete" forState:UIControlStateNormal];
  }
  else
  {
    [self.completeButton setTitle:@"Complete" forState:UIControlStateNormal];
  }

  CGRect frame = [self.body frame];
  CGSize size = [self.body sizeThatFits:CGSizeMake(frame.size.width, MAX_BODY_HEIGHT)];
  self.body.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
}

- (void)edit:(id)sender
{
  // load editing view into modal view
  UINavigationController *modal = [EditViewController navigationControllerWithTask:self.task];
  [self.navigationController presentModalViewController:modal animated:YES];
}

- (IBAction) complete:(id)sender
{
  self.task.complete = !self.task.complete;
  [self.task save];
  [self refresh];
}

#pragma mark Table view methods

- (void)dealloc
{
  [task release];
  [body release];
  [deleteButton release];
  [completeButton release];
  [super dealloc];
}

@end

