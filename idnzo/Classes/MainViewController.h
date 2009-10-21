
#import "TaskList.h"
#import "ListViewController.h"

@class ListViewController, TaskList;

@interface MainViewController : UITableViewController {
  ListViewController *listViewController;
  NSArray *taskLists;
}

@property (retain, nonatomic) NSArray *taskLists;
@property (nonatomic, retain) ListViewController *listViewController;

@end
