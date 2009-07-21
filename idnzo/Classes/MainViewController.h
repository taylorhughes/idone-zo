
#import "TaskList.h"
#import "ListViewController.h"

@class ListViewController, TaskList;

@interface MainViewController : UITableViewController {
  ListViewController *listViewController;
  NSArray *taskLists;
  NSManagedObjectContext *managedObjectContext;
}

@property (retain, nonatomic) NSArray *taskLists;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
