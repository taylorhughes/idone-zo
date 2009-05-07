//
//  EditViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()
@property (nonatomic, retain) TextFieldController *textFieldController;
- (void) saveBody:(id)sender;
@end

@implementation EditViewController

@synthesize task;
@synthesize textFieldController;

- (void)viewDidLoad
{
  [super viewDidLoad];
  if ([self.task existsInDB])
  {
    self.title = @"Edit task";
  }
  else
  {
    self.title = @"Add task";
  }
}

- (void)dealloc
{
  [task release];
  [textFieldController release];
  [super dealloc];
}

- (TextFieldController *)textFieldController
{
  if (!textFieldController)
  {
    self.textFieldController = [[[TextFieldController alloc] initWithNibName:@"BodyTextFieldView" bundle:nil] autorelease];
  }
  return textFieldController;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellAccessoryDisclosureIndicator;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 2;
}

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

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  UIViewController *controller = nil;
    
  switch ([indexPath section])
  {
    case 0:
      self.textFieldController.text = task.body;
      self.textFieldController.target = self;
      self.textFieldController.saveAction = @selector(saveBody:);
      controller = self.textFieldController;
      break;
      
    case 1:
      switch ([indexPath row])
      {
        case 0:
          break;
        case 1:
          break;
        case 2:
          break;
      }
      break;
  }
  
  if (controller)
  {
    [self.navigationController pushViewController:controller animated:YES];
  }
  
  return nil;
}

- (void) saveBody:(id)sender
{
  self.task.body = self.textFieldController.text;
  [self.task save];
  [self.tableView reloadData];
}

@end
