//
//  EditViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()

- (void) save:(id)sender;
- (void) cancel:(id)sender;

- (void) dismiss;

- (void) saveBody:(id)sender;
- (void) saveProject:(id)sender;

- (UITableViewCell*) cellWithReuseIdentifier:(NSString *)identifier;

@property (retain, nonatomic) NSObject *dismissTarget;
@property (assign, nonatomic) SEL dismissAction;

@end

@implementation EditViewController

@synthesize task, dismissTarget, dismissAction;

+ (UINavigationController*) navigationControllerWithTask:(Task*)task dismissTarget:(UIViewController*)target dismissAction:(SEL)action
{
  // load editing view into modal view
  EditViewController *evc = [[[EditViewController alloc] initWithNibName:@"EditTaskView" bundle:nil] autorelease];
  
  if (target) evc.dismissTarget = target;
  if (action) evc.dismissAction = action;
  
  UINavigationController *modalNavigationController = [[[UINavigationController alloc] initWithRootViewController:evc] autorelease];
  
  UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:evc
                                                                           action:@selector(cancel:)] autorelease];
  UIBarButtonItem *save   = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                           target:evc
                                                                           action:@selector(save:)] autorelease];
  
  evc.navigationItem.rightBarButtonItem = save;
  evc.navigationItem.leftBarButtonItem = cancel;
  evc.task = task;
  
  return modalNavigationController;
}
+ (UINavigationController*) navigationControllerWithTask:(Task*)task
{
  return [EditViewController navigationControllerWithTask:task dismissTarget:nil dismissAction:nil];
}

- (void)setTask:(Task*)newTask
{
  if (task)
  {
    [task release];
  }
  task = [newTask retain];
}

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

- (void)save:(id)sender
{
  [self.task save];
  [self dismiss];
}
- (void)cancel:(id)sender
{
  [self.task revert];
  [self dismiss];
}
- (void)dismiss
{
  if (dismissTarget && dismissAction)
  {
    [dismissTarget performSelector:dismissAction withObject:self];
  }
  [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
  [task release];
  
  
  [dismissTarget release];
  
  [super dealloc];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellAccessoryDisclosureIndicator;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch(section)
  {
    case 0: return nil; //@"Task Body";
    case 1: return @"Task Details";
  }
  return nil;
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

#define ROW_HEIGHT 50
#define ROW_WIDTH 280

#define PADDING 10
#define LEFT_COLUMN_WIDTH 60
#define TITLE_TAG 1
#define TEXT_TAG 2

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return ROW_HEIGHT;
}

- (UITableViewCell *)cellWithReuseIdentifier:(NSString *)identifier
{
	CGRect rect;
  
	rect = CGRectMake(0.0, 0.0, ROW_WIDTH, ROW_HEIGHT);
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
	
	UILabel *label;
	
	rect = CGRectMake(PADDING, PADDING, LEFT_COLUMN_WIDTH, ROW_HEIGHT - PADDING * 2);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = TITLE_TAG;
	label.font = [UIFont boldSystemFontOfSize:13];
  label.textAlignment = UITextAlignmentRight;
	label.adjustsFontSizeToFitWidth = YES;
	[cell.contentView addSubview:label];
	[label release];
	
	rect = CGRectMake(PADDING * 2 + LEFT_COLUMN_WIDTH, PADDING, ROW_WIDTH - LEFT_COLUMN_WIDTH - PADDING * 3, ROW_HEIGHT - PADDING * 2);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = TEXT_TAG;
	label.font = [UIFont systemFontOfSize:18];
	label.textAlignment = UITextAlignmentLeft;
	[cell.contentView addSubview:label];
	[label release];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"CellIdentifier";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil)
  {
		cell = [self cellWithReuseIdentifier:identifier];
	}
  
  UILabel *title = (UILabel *)[cell viewWithTag:TITLE_TAG];
  UILabel *text  = (UILabel *)[cell viewWithTag:TEXT_TAG];
  
  switch ([indexPath section])
  {
    case 0:
      title.text = @"body";
      text.text = self.task.body;
      
      break;
      
    case 1:
      switch ([indexPath row])
      {
        case 0:
          title.text = @"project";
          text.text = self.task.project.name;
          break;
        case 1:
          title.text = @"contexts";
          text.text = [self.task.contexts componentsJoinedByString:@", "];
          break;
        case 2:
          title.text = @"due date";
          text.text = [self.task.due descriptionWithCalendarFormat:@"%d/%m/%Y" timeZone:nil locale:nil];
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
      controller = [[[TextFieldController alloc] initWithNibName:@"BodyTextFieldView" bundle:nil] autorelease];
      
      ((TextFieldController*)controller).text = task.body;
      ((TextFieldController*)controller).target = self;
      ((TextFieldController*)controller).saveAction = @selector(saveBody:);
      
      break;
      
    case 1:
      switch ([indexPath row])
      {
        case 0: //project
          controller = [[[EditProjectPicker alloc] init] autorelease];
          ((EditProjectPicker*)controller).options = [Project projectNames];
          ((EditProjectPicker*)controller).selected = self.task.project.name;
          ((EditProjectPicker*)controller).target = self;
          ((EditProjectPicker*)controller).saveAction = @selector(saveProject:);
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
  self.task.body = [(TextFieldController*)sender text];
  [self.tableView reloadData];
}
- (void) saveProject:(id)sender
{
  NSString *newProject = [[(EditProjectPicker*)sender selected] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  Project *existingProject = [Project findProjectWithName:newProject];
  
  if (existingProject)
  {
    self.task.project = existingProject;
  }
  else
  {
    self.task.project = [[[Project alloc] init] autorelease];
    self.task.project.name = newProject;
  }
  
  [self.tableView reloadData];
}

@end
