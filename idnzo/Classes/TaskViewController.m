//
//  TaskViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"

@implementation TaskViewController

@synthesize completeButton, deleteButton, body, task;

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIBarButtonItem *edit = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                    target:self action:@selector(edit:)] autorelease];
  self.navigationItem.rightBarButtonItem = edit;
  
  [self refresh];
}

- (void)refresh
{
  self.body.text = self.task.body;
}


- (void)viewWillAppear:(BOOL)animated
{
  [self refresh];
}

- (void)edit:(id)sender
{
  // load editing view into modal view
  EditViewController *evc = [[[EditViewController alloc] initWithNibName:@"EditTaskView" bundle:nil] autorelease];
  UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:evc];
  
  UIBarButtonItem *dismiss = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                       target:self action:@selector(dismissModalViewControllerAnimated:)] autorelease];
  evc.navigationItem.rightBarButtonItem = dismiss;
  evc.task = self.task;
  
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];
}

#pragma mark Table view methods
/*
// This table will always only have one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 2;
}

// One row per book, the number of books is the number of rows.
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case 0:
      return 1;
    case 1:
      return 3;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
  if (cell == nil) {
    // Create a new cell. CGRectZero allows the cell to determine the appropriate size.
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
  }
  
  switch ([indexPath section])
  {
    case 0:
      cell.text = self.task.body;
      break;
      
    case 1:
      switch ([indexPath row])
    {
      case 0:
        cell.text = @"(project)";
        break;
      case 1:
        cell.text = @"(contexts)";
        break;
      case 2:
        cell.text = @"(due date)";
        break;
    }
      break;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

- (void)dealloc {
    [super dealloc];
}


@end

