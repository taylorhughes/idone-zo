//
//  EditProjectPicker.h
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Project.h"
#import "TextViewCell.h"

@class Project, TextViewCell;

@interface EditProjectPicker : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
  NSArray *options;
  NSObject *target;
  UITextView *textView;
  SEL saveAction;
  NSInteger selectedIndex;
}

- (NSString *)selected;
- (void)setSelected:(NSString*)newSelected;

@property (retain, nonatomic) NSArray  *options;
@property (nonatomic, retain) NSObject *target;
@property (nonatomic) SEL saveAction;

@end
