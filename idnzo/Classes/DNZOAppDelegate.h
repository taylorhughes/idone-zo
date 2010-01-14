//
//  DNZOAppDelegate.h
//  DNZO
//
//  Created by Taylor Hughes on 4/26/09.
//  Copyright Two-Stitch Software 2009. All rights reserved.
//

#import "MainViewController.h"
#import "Context.h"
#import "DonezoAPIClient.h"
#import "DonezoSyncMaster.h"
#import "DonezoSyncOperation.h"
#import "SettingsHelper.h"

@class Project, Context, TaskList, Task, MainViewController, DonezoSyncMaster;

extern NSString* const DonezoShouldSyncNotification;
extern NSString* const DonezoShouldResetAndSyncNotification;
extern NSString* const DonezoShouldResetNotification;
extern NSString* const DonezoDataUpdatedNotification;
extern NSString* const DonezoShouldFilterListNotification;

@interface DNZOAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  
  UINavigationController *navigationController;
  MainViewController *mainController;
  
  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;
  NSManagedObjectContext *syncManagedObjectContext;
  NSPersistentStoreCoordinator *persistentStoreCoordinator;
  
  DonezoAPIClient *donezoAPIClient;
  DonezoSyncMaster *syncMaster;
  
  NSOperationQueue *operationQueue;
  NSInteger networkIndicatorShown;
  BOOL hasDisplayedError;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet MainViewController *mainController;

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) DonezoAPIClient *donezoAPIClient;

- (void) showNetworkIndicator;
- (void) hideNetworkIndicator;

- (BOOL) waitForSyncToFinishAndReinitializeDatastore;

- (void) synchronouslySyncAll;

@end

