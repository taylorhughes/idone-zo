//
//  DatePickerViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 10/2/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

@interface DatePickerViewController : UIViewController {
  UIDatePicker *picker;
  UIButton *selectNoneButton;
  NSObject *target;
  SEL saveAction;
  
  BOOL noneSelected;
}

- (void)onClickSelectNoneButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIDatePicker *picker;
@property (retain, nonatomic) IBOutlet UIButton *selectNoneButton;
@property (retain, nonatomic) NSObject *target;
@property (nonatomic) SEL saveAction;
@property (copy, nonatomic) NSDate *selectedDate;

@end
