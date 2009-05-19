
#import "TaskList.h"
#import "Task.h"
#import "TaskViewController.h"
#import "TaskCell.h"
#import "TaskCellView.h"

@class TaskList, Task, TaskViewController, TaskCell, TaskCellView;

@interface ListViewController : UIViewController {
  IBOutlet UITableView *tableView;
  TaskList *taskList;
  NSArray *tasks;
  TaskViewController *taskViewController;
}

@property (nonatomic, retain) UITableView *tableView;
@property (retain, nonatomic) TaskList *taskList;
@property (retain, readonly, nonatomic) NSArray *tasks;
@property (retain, nonatomic) TaskViewController *taskViewController;

- (IBAction) archiveTasks:(id)sender;

@end
