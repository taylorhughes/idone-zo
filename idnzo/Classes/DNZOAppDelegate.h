//
//  DNZOAppDelegate.h
//  DNZO
//
//  Created by Taylor Hughes on 4/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SQLiteInstanceManager.h"
#import "TaskList.h"
#import "Task.h"
#import "Project.h"

@class SQLiteInstanceManager, TaskList, Task, Project;

@interface DNZOAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

