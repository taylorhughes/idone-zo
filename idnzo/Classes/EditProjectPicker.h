//
//  EditProjectPicker.h
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Project.h"

@class Project;

@interface EditProjectPicker : UITableViewController {
  NSArray *options;
  NSString *selected;
}

@property (copy, nonatomic)   NSString *selected;
@property (retain, nonatomic) NSArray  *options;

@end
