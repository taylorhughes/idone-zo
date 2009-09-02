//
//  DNZOAppDelegate.h
//  DNZO
//
//  Created by Taylor Hughes on 4/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MainViewController.h"
#import "Context.h"
#import "DonezoAPIClient.h"
#import "DonezoSyncMaster.h"

@class Project, Context, TaskList, Task, MainViewController;

extern NSString * const DonezoSyncStatusChangedNotification;

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
  BOOL isSyncing;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet MainViewController *mainController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *storePath;

@property (nonatomic, retain) DonezoAPIClient *donezoAPIClient;
@property (nonatomic, retain) DonezoSyncMaster *syncMaster;

@property (nonatomic, retain) NSOperationQueue *operationQueue;

- (void)sync;
- (BOOL)isSyncing;

@end

