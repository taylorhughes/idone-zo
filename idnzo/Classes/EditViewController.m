//
//  EditViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"

@implementation EditViewController

@synthesize task;

- (void)viewDidLoad {
  [super viewDidLoad];
  if ([self.task existsInDB]) {
    self.title = @"Edit task";
  } else {
    self.title = @"Add task";
  }
}

- (void)dealloc
{
  [task release];
  [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
  NSLog(@"Trying to return a number for the section...");
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
  NSLog(@"Coming up with a name for %s", indexPath );
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

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  return nil;
}


/*
- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField endEditing:YES];
  return YES;
}
*/


@end
