
#import "TaskList.h"

@class ListViewController, TaskList;

@interface MainViewController : UITableViewController {
  ListViewController *listViewController;
  NSArray *taskLists;
}

@property (retain, nonatomic) NSArray *taskLists;

@end
