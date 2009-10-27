//
//  FilterViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 10/25/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "Task.h"
#import "Project.h"
#import "Context.h"

@interface FilterViewController : UITableViewController {
  NSArray *contexts;
  NSArray *projects;
  NSArray *dueDates;
  NSArray *sections;
  
  NSIndexPath *selectedPath;
}

@property (nonatomic, retain) NSArray *contexts;
@property (nonatomic, retain) NSArray *projects;
@property (nonatomic, retain) NSArray *dueDates;

@property (nonatomic, readonly) NSManagedObject *selectedObject;

@end
