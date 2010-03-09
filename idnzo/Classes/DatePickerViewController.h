//
//  DatePickerViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 10/2/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

@interface DatePickerViewController : UIViewController <UITableViewDelegate,UITableViewDataSource> {
  UIDatePicker *picker;
  UIButton *selectNoneButton;
  UITableView *tableView;
  NSObject *target;
  SEL saveAction;
  
  BOOL noneSelected;
}

- (void)onClickSelectNoneButton:(id)sender;
- (IBAction)pickerValueChanged:(id)sender;
- (void)updateTextField;

@property (retain, nonatomic) IBOutlet UIDatePicker *picker;
@property (retain, nonatomic) IBOutlet UIButton *selectNoneButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSObject *target;
@property (nonatomic) SEL saveAction;
@property (copy, nonatomic) NSDate *selectedDate;

@end
