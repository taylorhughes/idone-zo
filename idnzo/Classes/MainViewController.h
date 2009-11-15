
#import "TaskList.h"
#import "ListViewController.h"
#import "ArchivedListViewController.h"
#import "TextFieldViewController.h"

@class ListViewController, ArchivedListViewController, TaskList;

@interface MainViewController : UITableViewController {
  ListViewController *listViewController;
  ArchivedListViewController *archivedListViewController;
  NSArray *taskLists;
}

@property (retain, nonatomic) NSArray *taskLists;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, retain) ArchivedListViewController *archivedListViewController;

@end