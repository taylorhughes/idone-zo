//
//  TaskViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"

@interface TaskViewController ()

@property (nonatomic, retain) NSManagedObjectContext *editingContext;

@end

@implementation TaskViewController

@synthesize completeButton, deleteButton, body, task;
@synthesize editingContext;

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIBarButtonItem *edit = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                         target:self
                                                                         action:@selector(edit:)] autorelease];
  self.navigationItem.rightBarButtonItem = edit;
  
  [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self refresh];
}

// I don't think this has any effect.
#define MAX_BODY_HEIGHT 100

- (void)refresh
{
  self.body.text = self.task.body;
  if (self.task.isComplete)
  {
    [self.completeButton setTitle:@"Uncomplete" forState:UIControlStateNormal];
  }
  else
  {
    [self.completeButton setTitle:@"Complete" forState:UIControlStateNormal];
  }

  CGRect frame = [self.body frame];
  CGSize size = [self.body sizeThatFits:CGSizeMake(frame.size.width, MAX_BODY_HEIGHT)];
  self.body.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
}

- (void)editingContextDidSave:(NSNotification*)saveNotification
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];	
}

- (void)editTaskCanceled
{
  self.editingContext = nil;
}

- (void)editTaskSaved
{
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self selector:@selector(editingContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.editingContext];
  
  NSError *error;
  if (![self.editingContext save:&error])
  {
    // Update to handle the error appropriately.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }
  [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.editingContext];
  
  self.editingContext = nil;
}

- (void)edit:(id)sender
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  
	// Create a new managed object context for the new book -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	self.editingContext = [[[NSManagedObjectContext alloc] init] autorelease];
	[self.editingContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
  
  
  Task *editingTask = (Task*)[self.editingContext objectWithID:[self.task objectID]];
  
  // load editing view into modal view
  UINavigationController *modalNavigationController = [EditViewController navigationControllerWithTask:editingTask
                                                                                         dismissTarget:self  
                                                                                            saveAction:@selector(editTaskSaved)
                                                                                          cancelAction:@selector(editTaskCanceled)];
  
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];
}

- (IBAction) complete:(id)sender
{
  self.task.isComplete = !self.task.isComplete;
  [self.task hasBeenUpdated];
  [self refresh];
}

#pragma mark Table view methods

- (void)dealloc
{
  [task release];
  [body release];
  [deleteButton release];
  [completeButton release];
  [super dealloc];
}

@end

