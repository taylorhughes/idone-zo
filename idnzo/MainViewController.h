
#import "TaskList.h"

@class ListViewController, TaskList;

@interface MainViewController : UIViewController {
  ListViewController *listViewController;
  IBOutlet UINavigationController *navigationController;
  IBOutlet UITableView *tableView;
  
  NSArray *taskLists;
}

@property (retain, nonatomic) NSArray *taskLists;

@end
