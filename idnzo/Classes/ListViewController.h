
#import "DNZOAppDelegate.h"
#import "TaskList.h"
#import "Task.h"
#import "TaskViewController.h"
#import "MainViewController.h"
#import "SortViewController.h"
#import "FilterViewController.h"
#import "TaskCell.h"
#import "TaskCellView.h"

@class TaskList, Task, TaskViewController, MainViewController, SortViewController, \
       FilterViewController, TaskCell, TaskCellView;

@interface ListViewController : UIViewController <UIActionSheetDelegate> {
  IBOutlet UITableView *tableView;
  TaskList *taskList;
  NSArray *tasks;
  NSArray *filteredTasks;
  
  TaskViewController *taskViewController;
  SortViewController *sortViewController;
  FilterViewController *filterViewController;
  
  BOOL suspendUpdates;
}

@property (nonatomic, retain) UITableView *tableView;
@property (retain, nonatomic) TaskList *taskList;
@property (retain, readonly, nonatomic) NSArray *tasks;
@property (retain, readonly, nonatomic) NSArray *filteredTasks;

@property (readonly, nonatomic) NSObject *filteredObject;
@property (readonly, nonatomic) NSString *sortKey;
@property (readonly, nonatomic) BOOL      sortDescending;

@property (retain, nonatomic) TaskViewController *taskViewController;

- (IBAction) askToArchiveTasks:(id)sender;
- (IBAction) sort:(id)sender;
- (IBAction) filter:(id)sender;
- (IBAction) sync:(id)sender;

@end
