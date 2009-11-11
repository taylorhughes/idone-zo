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

- (void) dismiss:(BOOL)saved;

- (void) saveProject:(id)sender;

- (UITableViewCell*) detailCellWithReuseIdentifier:(NSString *)identifier;
- (UITableViewCell*) bodyCellWithReuseIdentifier:(NSString *)identifier;

@property (retain, nonatomic) NSObject *dismissTarget;
@property (assign, nonatomic) SEL cancelAction;
@property (assign, nonatomic) SEL saveAction;

@end

@implementation EditViewController

@synthesize task, dismissTarget, saveAction, cancelAction;

+ (UINavigationController*) navigationControllerWithTask:(Task*)task dismissTarget:(UIViewController*)target saveAction:(SEL)saveAction cancelAction:(SEL)cancelAction
{
  // load editing view into modal view
  EditViewController *evc = [[[EditViewController alloc] initWithNibName:@"EditTaskView" bundle:nil] autorelease];
  
  evc.dismissTarget = target;
  evc.saveAction = saveAction;
  evc.cancelAction = cancelAction;
  
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
  return [EditViewController navigationControllerWithTask:task dismissTarget:nil saveAction:nil cancelAction:nil];
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
  if ([self.task objectID])
  {
    self.title = @"Edit task";
  }
  else
  {
    self.title = @"Add task";
  }
}

#define BODY_ROW_HEIGHT 100
#define DETAIL_ROW_HEIGHT 50
#define ROW_WIDTH 280

#define PADDING 10
#define TEXTVIEW_PADDING 5
#define LEFT_COLUMN_WIDTH 60
#define TITLE_TAG 1
#define TEXT_TAG 2
#define TEXTVIEW_TAG 3

#define SMALL_FONT_SIZE 12.0
#define REGULAR_FONT_SIZE 18.0

- (void)save:(id)sender
{
  UITextView *textView = (UITextView*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:TEXTVIEW_TAG];
  self.task.body = textView.text;
  [self.task hasBeenUpdated];
  [self dismiss:YES];
}
- (void)cancel:(id)sender
{
  [self dismiss:NO];
}
- (void)dismiss:(BOOL)saved
{
  if (dismissTarget)
  {
    [dismissTarget performSelector:(saved ? saveAction : cancelAction) withObject:self];
  }
  [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
  [task release];
  [textViewController release];
  [dismissTarget release];
  
  [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch(section)
  {
    case 0: return @"Task Body";
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    return BODY_ROW_HEIGHT;
  }
  return DETAIL_ROW_HEIGHT;
}

- (UITableViewCell *)bodyCellWithReuseIdentifier:(NSString *)identifier
{
  CGRect rect = CGRectMake(TEXTVIEW_PADDING, TEXTVIEW_PADDING, ROW_WIDTH - TEXTVIEW_PADDING * 2, BODY_ROW_HEIGHT - TEXTVIEW_PADDING * 2);
  UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
  UITextView *textView = [[[UITextView alloc] initWithFrame:rect] autorelease];
  textView.tag = TEXTVIEW_TAG;
  textView.delegate = self;
  textView.returnKeyType = UIReturnKeyDone;
  textView.font = [UIFont systemFontOfSize:REGULAR_FONT_SIZE];
  [cell.contentView addSubview:textView];
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  return cell;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  if ([text isEqual:@"\n"])
  {
    [textView resignFirstResponder];
    return NO;
  }
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
  self.task.body = textView.text;
}

- (UITableViewCell *)detailCellWithReuseIdentifier:(NSString *)identifier
{
	CGRect rect = CGRectMake(0.0, 0.0, ROW_WIDTH, DETAIL_ROW_HEIGHT);
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
	
  UILabel *label = nil;
  
	rect = CGRectMake(PADDING, PADDING, LEFT_COLUMN_WIDTH, DETAIL_ROW_HEIGHT - PADDING * 2);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = TITLE_TAG;
	label.font = [UIFont boldSystemFontOfSize:SMALL_FONT_SIZE];
  label.textAlignment = UITextAlignmentRight;
	label.adjustsFontSizeToFitWidth = YES;
	[cell.contentView addSubview:label];
	[label release];
	
	rect = CGRectMake(PADDING * 2 + LEFT_COLUMN_WIDTH, PADDING, ROW_WIDTH - LEFT_COLUMN_WIDTH - PADDING * 3, DETAIL_ROW_HEIGHT - PADDING * 2);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = TEXT_TAG;
	label.font = [UIFont systemFontOfSize:REGULAR_FONT_SIZE];
	label.textAlignment = UITextAlignmentLeft;
	[cell.contentView addSubview:label];
	[label release];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
  
  UILabel *title;
  UILabel *text;
  
  switch ([indexPath section])
  {
    case 0:
      cell = [self.tableView dequeueReusableCellWithIdentifier:@"BodyCell"];
      if (cell == nil) {
        cell = [self bodyCellWithReuseIdentifier:@"BodyCell"];
      }
      
      ((UITextView*)[cell viewWithTag:TEXTVIEW_TAG]).text = self.task.body;
      
      break;
      
    case 1:
    default:
      cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
      if (cell == nil) {
        cell = [self detailCellWithReuseIdentifier:@"DetailCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }
      title = (UILabel *)[cell viewWithTag:TITLE_TAG];
      text  = (UILabel *)[cell viewWithTag:TEXT_TAG];
      
      switch ([indexPath row])
      {
        case 0:
          title.text = @"project";
          text.text = self.task.project.name;
          break;
        case 1:
          title.text = @"contexts";
          //text.text = self.task.contextsString;
          break;
        case 2:
          title.text = @"due date";
          //text.text = self.task.dueString;
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
      break;
      
    case 1:
      switch ([indexPath row])
      {
        case 0: //project
          controller = [[[EditProjectPicker alloc] init] autorelease];
          ((EditProjectPicker*)controller).options = [Project projectNames:[self.task managedObjectContext]];
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

- (void) saveProject:(id)sender
{
  NSString *newProject = [[(EditProjectPicker*)sender selected] 
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  self.task.project = [Project findOrCreateProjectWithName:newProject inContext:[self.task managedObjectContext]];
  
  [self.tableView reloadData];
}

@end
