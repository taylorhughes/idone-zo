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
@synthesize tableView;
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
  // ... so this stuff has an effect
  if (!date)
  {
    // Output the current date to a string, then read it back in as UTC;
    // this allows us to get the current date as 10/10/2010 00:00:00 UTC, 
    // for example if it's 10/10/2010 in the current timezone but not in UTC.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *stringDate = [formatter stringFromDate:[NSDate date]];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    date = [formatter dateFromString:stringDate];
    [formatter release];
  }
  
  [self.picker setDate:date animated:NO];
  [self updateTextField];
}

- (void)onClickSelectNoneButton:(id)sender
{
  noneSelected = YES;
  [self updateTextField];
}

- (IBAction)pickerValueChanged:(id)sender
{
  noneSelected = NO;
  [self updateTextField];
}

- (void)updateTextField
{
  [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"Cell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
  }
    
  NSDate *date = [self selectedDate];
  cell.textLabel.text = @"";
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  if (date)
  {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    cell.textLabel.text = [formatter stringFromDate:date];
    [formatter release];
  }
  
  return cell;
}

- (void)dealloc
{
  [picker release];
  [target release];
  [super dealloc];
}

@end
