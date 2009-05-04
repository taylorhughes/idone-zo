//
//  DNZOAppDelegate.m
//  DNZO
//
//  Created by Taylor Hughes on 4/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "DNZOAppDelegate.h"

static NSString *DATABASE_FILENAME     = @"dnzo.sqlite";
static NSString *DATABASE_SQL_FILENAME = @"tasks.sql";

@interface DNZOAppDelegate (Private)
- (void) createDatabaseIfNeeded;
@end

@implementation DNZOAppDelegate

@synthesize window, navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  // Create the database if it doesn't exist yet
  [self createDatabaseIfNeeded];

  // Add the current view in the navigationController to the main window.
  [window addSubview:navigationController.view];
  [window makeKeyAndVisible];
}


- (void)dealloc {
  [navigationController release];
  [window release];
  [super dealloc];
}

- (void)createDatabaseIfNeeded {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILENAME];
  
  if ([fileManager fileExistsAtPath:databasePath]) {
    NSLog(@"Database already exists!");
    return;
  } else {
    NSLog(@"Attempting to create database...");
  }
  
  // Open the database. This should create a new blank database.
  if (sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
    sqlite3_close(database);
    NSAssert1(0, @"Failed to create database with message '%s'.", sqlite3_errmsg(database));
  } else {
    NSLog(@"Created the database, now adding the tables...");
    
    NSString *sqlPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_SQL_FILENAME];
    
    const char *sql = [[NSString stringWithContentsOfFile:sqlPath] UTF8String];
    char *error;
    sqlite3_exec(database, sql, NULL, NULL, &error);
    if (error) {
      NSAssert1(0, @"Failed to create database tables with message '%s'.", error);
    } else {
      NSLog(@"Created the database tables.");
    }
  }
}

@end
