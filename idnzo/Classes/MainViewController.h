
#import "TaskList.h"
#import "ListViewController.h"
#import "ArchivedListViewController.h"
#import "SettingsViewController.h"
#import "TextFieldViewController.h"

@class ListViewController, ArchivedListViewController, TaskList, SettingsViewController;

@interface MainViewController : UITableViewController {
  ListViewController *listViewController;
  ArchivedListViewController *archivedListViewController;
  SettingsViewController *settingsViewController;
  NSArray *taskLists;
  
  NSArray *archivedLabels;
}

@property (retain, nonatomic) NSArray *taskLists;
@property (nonatomic, readonly) ListViewController *listViewController;
@property (nonatomic, readonly) ArchivedListViewController *archivedListViewController;
@property (nonatomic, readonly) SettingsViewController *settingsViewController;

@property (nonatomic, readonly) NSArray *archivedLabels;

- (NSArray*)getStartAndEndDatesForArchivedLabelPosition:(NSUInteger)index;

@end