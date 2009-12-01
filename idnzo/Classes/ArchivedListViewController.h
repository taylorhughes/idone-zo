//
//  ArchivedListViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 11/14/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "DNZOAppDelegate.h"

@interface ArchivedListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  NSDate *start;
  NSDate *end;
  
  // Array of local Task* objects
  NSArray *localTasks;
  // Array of remote DonezoTask* objects
  NSArray *remoteTasks;
  NSOperationQueue *queue;
  
  UIView *loadingView;
  
  UITableView *tableView;
}

// Atomic is the default
@property (copy) NSDate *start;
@property (copy) NSDate *end;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

@property (nonatomic, retain) NSArray *localTasks;
@property (retain) NSArray *remoteTasks;

// Returns a sorted array of Task* and DonezoTask* objects,
// sorted with a common sorter
- (NSArray*) allTasks;

@end