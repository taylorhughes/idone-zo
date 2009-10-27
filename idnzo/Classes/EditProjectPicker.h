//
//  EditProjectPicker.h
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "Project.h"
#import "GTMRegex.h"

@class Project;

@interface EditProjectPicker : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  NSArray *options;
  UITextField *textField;
  NSObject *target;
  SEL saveAction;
  BOOL appendSelections;
  NSString *title;
}

- (NSString *)selected;
- (void)setSelected:(NSString*)newSelected;

@property (retain, nonatomic) NSArray  *options;
@property (retain, nonatomic) NSObject *target;
@property (nonatomic) BOOL appendSelections;
@property (nonatomic) SEL saveAction;
@property (retain, nonatomic) NSString *placeholder;
@property (retain, nonatomic) NSString *title;

@end
