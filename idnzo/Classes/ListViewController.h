
#import "TaskList.h"
#import "Task.h"
#import "TaskViewController.h"

@class TaskList, Task, TaskViewController;

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

- (IBAction) addNewTask:(id)sender;

@end
