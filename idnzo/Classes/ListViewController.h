
#import "DNZOAppDelegate.h"
#import "TaskList.h"
#import "Task.h"
#import "TaskViewController.h"
#import "MainViewController.h"
#import "TaskCell.h"
#import "TaskCellView.h"

@class TaskList, Task, TaskViewController, MainViewController, TaskCell, TaskCellView;

@interface ListViewController : UIViewController {
  IBOutlet UITableView *tableView;
  TaskList *taskList;
  NSArray *tasks;
  TaskViewController *taskViewController;

  UIBarButtonItem *syncButton;
}

@property (nonatomic, retain) UITableView *tableView;
@property (retain, nonatomic) TaskList *taskList;
@property (retain, readonly, nonatomic) NSArray *tasks;
@property (retain, nonatomic) TaskViewController *taskViewController;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *syncButton;

- (IBAction) archiveTasks:(id)sender;

@end
