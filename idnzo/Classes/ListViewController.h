
#import "TaskList.h"
#import "Task.h"
#import "EditViewController.h"

@class TaskList, Task, EditViewController;

@interface ListViewController : UIViewController {
  IBOutlet UITableView *tableView;
  TaskList *taskList;
  NSArray *tasks;
  EditViewController *editViewController;
}

@property (nonatomic, retain) UITableView *tableView;
@property (retain, nonatomic) TaskList *taskList;
@property (retain, readonly, nonatomic) NSArray *tasks;
@property (retain, nonatomic) EditViewController *editViewController;

@end
