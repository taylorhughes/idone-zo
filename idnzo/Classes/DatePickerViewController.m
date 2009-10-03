//
//  DatePickerViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 10/2/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "DatePickerViewController.h"


@implementation DatePickerViewController

@synthesize picker;
@synthesize selectNoneButton;
@synthesize target;
@synthesize saveAction;

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    noneSelected = NO;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
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
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  noneSelected = NO;
}

- (void)save:(id)sender
{  
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

- (NSDate*)selectedDate
{
  if (noneSelected)
  {
    return nil;
  }
  return self.picker.date;
}
- (void)setSelectedDate:(NSDate*)date
{
  self.picker.date = date ? date : [NSDate date];
}

- (void)onClickSelectNoneButton:(id)sender
{
  noneSelected = YES;
  [self save:sender];
}

- (void)dealloc
{
  [picker release];
  [target release];
  [super dealloc];
}

@end
