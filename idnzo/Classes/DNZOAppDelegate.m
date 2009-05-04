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
- (void) openDatabase;
- (void) createDatabaseIfNeeded;
@end

@implementation DNZOAppDelegate

@synthesize window, navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  [self openDatabase];
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

- (void)openDatabase {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILENAME];

  if (sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
    sqlite3_close(database);
    NSAssert1(0, @"Failed to open or create database with message '%s'.", sqlite3_errmsg(database));
  }
  
  [DNZODataObject setDatabase:database];
}

- (void)createDatabaseIfNeeded {
  char *dbError;
  
  const char *testSQL = "SELECT key FROM tasks LIMIT 1;"; 
  sqlite3_exec(database, testSQL, NULL, NULL, &dbError);
  if (!dbError) {
    NSLog(@"Database already exists.");
    return;
  }
  
  NSString *sqlPath = [
    [[NSBundle mainBundle] resourcePath] 
    stringByAppendingPathComponent:DATABASE_SQL_FILENAME
  ];
  
  // Read SQL from the SQL file in the resources directory
  const char *createSQL = [[NSString stringWithContentsOfFile:sqlPath] UTF8String];
  sqlite3_exec(database, createSQL, NULL, NULL, &dbError);
  if (dbError) {
    NSAssert1(0, @"Failed to create database tables with message '%s'.", dbError);
  } else {
    NSLog(@"Created the database tables.");
  }
}

// Save all changes to the database, then close it.
- (void)applicationWillTerminate:(UIApplication *)application {
  if (sqlite3_close(database) != SQLITE_OK) {
    NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
  }
}

@end
