#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ListViewController : UIViewController {
  NSString *contents;
  IBOutlet UITableView *tableView;
}

@property (retain, nonatomic) NSString *contents;

@end
