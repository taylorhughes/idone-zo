#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "TaskList.h"
#import "Task.h"

@class TaskList, Task;

@interface ListViewController : UIViewController {
  IBOutlet UITableView *tableView;
  TaskList *taskList;
  NSArray *tasks;
}

@property (nonatomic, retain) UITableView *tableView;
@property (retain, nonatomic) TaskList *taskList;
@property (retain, readonly, nonatomic) NSArray *tasks;

@end
