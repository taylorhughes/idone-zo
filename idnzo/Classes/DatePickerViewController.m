//
//  DatePickerViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 10/2/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
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
  
  self.picker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.navigationItem.title = @"Due Date";
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
  // This line forces the nibfile to load the view
  self.view;
  // ... so that this line has an effect
  if (!date)
  {
    // Output the current date to a string, then read it back in as UTC;
    // this allows us to get the current date as 10/10/2010 00:00:00 UTC, 
    // for example if it's 10/10/2010 in the current timezone but not in UTC.
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] retain];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *stringDate = [formatter stringFromDate:[NSDate date]];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    date = [formatter dateFromString:stringDate];
  }
  [self.picker setDate:date animated:NO];
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
