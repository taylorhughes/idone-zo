#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class ListViewController;

@interface MainViewController : UIViewController {
  ListViewController *listViewController;
  IBOutlet UINavigationController *navigationController;
  IBOutlet UITableView *tableView;
}

@end
