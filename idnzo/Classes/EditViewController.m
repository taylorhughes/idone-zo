//
//  EditViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()
- (void) saveBody:(id)sender;
- (UITableViewCell*) cellWithReuseIdentifier:(NSString *)identifier;
@end

@implementation EditViewController

@synthesize task;

+ (UINavigationController*) navigationControllerWithTask:(Task*)task dismissTarget:(UIViewController*)target dismissAction:(SEL)action
{
  // load editing view into modal view
  EditViewController *evc = [[[EditViewController alloc] initWithNibName:@"EditTaskView" bundle:nil] autorelease];
  UINavigationController *modalNavigationController = [[[UINavigationController alloc] initWithRootViewController:evc] autorelease];
  
  UIBarButtonItem *dismiss = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                            target:target
                                                                            action:action] autorelease];
  evc.navigationItem.rightBarButtonItem = dismiss;
  evc.task = task;
  
  return modalNavigationController;
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

- (void)dealloc
{
  [task release];
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
#define BODY_TAG 2

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
	//label.highlightedTextColor = [UIColor whiteColor];
	[label release];
	
	rect = CGRectMake(PADDING * 2 + LEFT_COLUMN_WIDTH, PADDING, ROW_WIDTH - LEFT_COLUMN_WIDTH - PADDING * 3, ROW_HEIGHT - PADDING * 2);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = BODY_TAG;
	label.font = [UIFont systemFontOfSize:18];
	label.textAlignment = UITextAlignmentLeft;
	[cell.contentView addSubview:label];
	//label.highlightedTextColor = [UIColor whiteColor];
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
  UILabel *body  = (UILabel *)[cell viewWithTag:BODY_TAG];
	
  switch ([indexPath section])
  {
    case 0:
      title.text = @"body";
      body.text = self.task.body;
      
      break;
      
    case 1:
      switch ([indexPath row])
      {
        case 0:
          title.text = @"project";
          break;
        case 1:
          title.text = @"contexts";
          break;
        case 2:
          title.text = @"due date";
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
  self.task.body = [(TextFieldController*)sender text];
  [self.task save];
  [self.tableView reloadData];
}

@end
