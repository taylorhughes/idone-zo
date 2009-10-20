//
//  TaskViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"

#define FADE_ANIMATION_DURATION 0.2

static UIImage *checked;
static UIImage *unchecked;

@interface TaskViewController ()

@property (nonatomic, retain) NSManagedObjectContext *editingContext;
@property (nonatomic, retain) Task *task;

- (void) onClickEdit:(id)sender;
- (void) onClickCancel:(id)sender;
- (void) onClickDone:(id)sender;

- (void) createEditingContext;
- (void) edit:(BOOL)animated;
- (void) cancel:(BOOL)animated;

- (void) save;
- (void) save:(BOOL)doRefresh;

- (void) refresh;
- (void) refreshHeaderAndFooter;

- (IBAction) hideDeleteTaskConfirmation:(id)sender doPop:(BOOL)doPopView;

- (BOOL)hasProject;
- (BOOL)hasContexts;
- (BOOL)hasDueDate;

@end

@implementation TaskViewController

+ (void) initialize
{
  if (self == [TaskViewController class])
  {
    checked = [[UIImage imageNamed:@"checked.png"] retain];
    unchecked = [[UIImage imageNamed:@"unchecked.png"] retain];
  }
}

@synthesize task;
@synthesize editingContext;
@synthesize isEditing;

- (id) init
{
  self = [super init];
  if (self != nil)
  {
    isNewTask = NO;
    isEditing = NO;
  }
  return self;
}

- (void) viewDidLoad
{
  [super viewDidLoad];  
  if (self.tableView.tableHeaderView == nil)
  {
    [topButton addTarget:self action:@selector(editNameClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topButton.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
    [topCheckmark addTarget:self action:@selector(checkmarkClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableHeaderView = [[[UIView alloc] init] autorelease];
    [self.tableView.tableHeaderView addSubview:bodyView];
    [self.tableView.tableHeaderView addSubview:bodyEditView];
    
    bottomView.alpha = 0.0;
    [self.tableView addSubview:bottomView];
    
    [self cancel:NO];
  }
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  // This is important because by now self.view has the proper bounds
  [self refresh];
}

- (BOOL) isNewTask
{
  return isNewTask;
}

- (void) loadEditingWithNewTaskForList:(TaskList*)list
{
  isNewTask = YES;
  // This initial refresh is necessary or inserting rows for edit will not work
  [self refresh];
  [self loadTask:nil editing:YES];
  self.task.taskList = (TaskList*)[self.editingContext objectWithID:[list objectID]];
}

- (void) loadTask:(Task*)newTask editing:(BOOL)editing
{
  self.task = newTask;
  
  if (!editing)
  {
    // cancel edit
    [self cancel:NO];
  }
  else 
  {
    // begin edit
    [self edit:NO];
  }
}

- (void) createEditingContext
{  
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  
	// Create a new managed object context for the new book -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	self.editingContext = [[[NSManagedObjectContext alloc] init] autorelease];
	[self.editingContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
  
  if (self.task != nil)
  {
    self.task = (Task*)[self.editingContext objectWithID:[self.task objectID]];
  }
  else
  {
    self.task = (Task*)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.editingContext];
  }
}

- (void) edit:(BOOL)animated
{  
  [self createEditingContext];
  
  // Change the buttons
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        target:self
                                                                        action:@selector(onClickDone:)];
  [self.navigationItem setRightBarButtonItem:done animated:animated];
  [done release];
  
  if ([self isNewTask])
  {
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(onClickCancel:)];
    [self.navigationItem setLeftBarButtonItem:cancel animated:animated];
    [cancel release];
  }
  [self.navigationItem setHidesBackButton:YES animated:animated];  
  
  // insert rows that were not shown previously
  
  NSMutableArray* insertedPaths = [NSMutableArray arrayWithCapacity:3];
  NSMutableArray* updatedPaths = [NSMutableArray arrayWithCapacity:3];
  
  UITableViewRowAnimation animation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
  
  [([self hasProject]) ?  updatedPaths : insertedPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
  [([self hasContexts]) ? updatedPaths : insertedPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
  [([self hasDueDate]) ?  updatedPaths : insertedPaths addObject:[NSIndexPath indexPathForRow:2 inSection:0]];
  
  isEditing = YES;
  
  [self.tableView insertRowsAtIndexPaths:insertedPaths withRowAnimation:animation];
  [self.tableView reloadRowsAtIndexPaths:updatedPaths withRowAnimation:animation];
    
  if (animated)
  {
    [UIView beginAnimations:@"beginEditing" context:nil];
  }
  
  bodyView.alpha = 0.0;
  bodyEditView.alpha = 1.0;
  if (!isNewTask)
  {
    bottomView.alpha = 1.0;
  }
  [self refreshHeaderAndFooter];
  
  if (animated)
  {
    [UIView commitAnimations];
  }
}

- (void) cancel:(BOOL)animated
{
  UIBarButtonItem *edit = nil;
  if (!self.task.isComplete)
  {
    edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                         target:self
                                                         action:@selector(onClickEdit:)];
  }
  [self.navigationItem setRightBarButtonItem:edit animated:animated];
  [edit release];
  
  [self.navigationItem setHidesBackButton:NO animated:animated];
    
  // remove unused rows
  
  BOOL wasEditing = isEditing;
  isEditing = NO;
  
  if (wasEditing && animated)
  {
    NSMutableArray* deletedPaths = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray* updatedPaths = [NSMutableArray arrayWithCapacity:3];
    
    UITableViewRowAnimation animation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
    
    NSInteger numRows = [self hasProject] + [self hasContexts] + [self hasDueDate];
    if (![self hasProject])
    {
      [deletedPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    else if (numRows >= 1)
    {
      [updatedPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    if (![self hasContexts])
    {
      [deletedPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];  
    }
    else if (numRows >= 2)
    {
      [updatedPaths addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
    }
    if (![self hasDueDate])
    {
      [deletedPaths addObject:[NSIndexPath indexPathForRow:2 inSection:0]];
    }
    else if (numRows == 3)
    {
      [updatedPaths addObject:[NSIndexPath indexPathForRow:2 inSection:0]];
    }
    
    [self.tableView deleteRowsAtIndexPaths:deletedPaths withRowAnimation:animation];
    [self.tableView reloadRowsAtIndexPaths:updatedPaths withRowAnimation:animation];    
  }
  else
  {
    [self refresh];
  }
  
  if (animated)
  {
    [UIView beginAnimations:@"beginCanceling" context:nil];
  }
  
  bodyView.alpha = 1.0;
  bodyEditView.alpha = 0.0;
  bottomView.alpha = self.task.isComplete ? 1.0 : 0.0;
  [self refreshHeaderAndFooter];
  
  if (animated)
  {
    [UIView commitAnimations];
  }
}

- (void) refreshHeaderAndFooter
{
  CGFloat width = topLabel.frame.size.width;
  // Resize body cell according to how tall the text is
  CGSize newSize = [self.task.body sizeWithFont:topLabel.font
                              constrainedToSize:CGSizeMake(width, 300.0f)
                                  lineBreakMode:UILineBreakModeWordWrap];
  
  CGFloat newHeight = newSize.height >= topLabel.font.pointSize ? newSize.height : topLabel.font.pointSize;
  CGFloat heightDiff = newHeight - topLabel.frame.size.height;

  topLabel.text = self.task.body;
  [topButton setTitle:self.task.body forState:UIControlStateNormal];
    
  // NOTE: We don't reset the heights here, we just add the *difference* in the height.
  topLabel.frame = CGRectMake(topLabel.frame.origin.x,
                              topLabel.frame.origin.y,
                              topLabel.frame.size.width,
                              topLabel.frame.size.height + heightDiff);
  topButton.frame = CGRectMake(topButton.frame.origin.x,
                               topButton.frame.origin.y,
                               topButton.frame.size.width,
                               topButton.frame.size.height + heightDiff);
  
  bodyView.frame = CGRectMake(bodyView.frame.origin.x,
                              bodyView.frame.origin.y,
                              bodyView.frame.size.width,
                              bodyView.frame.size.height + heightDiff);
  bodyEditView.frame = CGRectMake(bodyEditView.frame.origin.x,
                                  bodyEditView.frame.origin.y,
                                  bodyEditView.frame.size.width,
                                  bodyEditView.frame.size.height + heightDiff);
  
  self.tableView.tableHeaderView.frame = !self.isEditing ? bodyView.frame : bodyEditView.frame;
  // Forces the size to be reloaded
  self.tableView.tableHeaderView = self.tableView.tableHeaderView;
  
  CGRect footerFrame = bottomView.frame;
  CGRect sectionFrame = [self.tableView rectForSection:0];
  footerFrame.origin = CGPointMake(footerFrame.origin.x, self.tableView.tableHeaderView.frame.size.height + sectionFrame.size.height);
  bottomView.frame = footerFrame;
}

- (void) refresh
{
  [topCheckmark setImage:(self.task.isComplete ? checked : unchecked) forState:UIControlStateNormal];
  
  [self refreshHeaderAndFooter];
  [self.tableView reloadData];
}

- (void)editNameClicked:(id)sender
{
  TextFieldController *controller = [[TextFieldController alloc] init];
  controller.textView.font = [UIFont systemFontOfSize:17.0f];
  controller.text = self.task.body;
  controller.target = self; 
  controller.saveAction = @selector(editNameSaved:);
  [self.navigationController pushViewController:controller animated:YES];
  [controller release];
}

- (void)editNameSaved:(id)sender
{
  self.task.body = [(TextFieldController*)sender text];
  if (![self isNewTask])
  {
    [self save];
  }
}

- (void) saveProject:(id)sender
{
  NSString *newProject = [(EditProjectPicker*)sender selected];
  
  self.task.project = [Project findOrCreateProjectWithName:newProject inContext:[self.task managedObjectContext]];
  if (![self isNewTask])
  {
    [self save];
  }
}
- (void) saveContexts:(id)sender
{
  NSString *contexts = [[(EditProjectPicker*)sender selected] lowercaseString];
  NSMutableCharacterSet *set = [NSMutableCharacterSet lowercaseLetterCharacterSet];
  [set formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
  [set addCharactersInString:@"-_"];
  [set invert];
  
  NSMutableArray *contextsArray = [NSMutableArray arrayWithArray:[contexts componentsSeparatedByCharactersInSet:set]];
  for (int i = [contextsArray count] - 1; i >= 0; i--)
  {
    if ([[contextsArray objectAtIndex:i] isEqual:@""])
    {
      [contextsArray removeObjectAtIndex:i];
    }
  }
  
  self.task.contexts = [NSSet setWithArray:[Context findOrCreateContextsWithNames:contextsArray inContext:[self.task managedObjectContext]]];
  if (![self isNewTask])
  {
    [self save];
  }
}
- (void)saveDate:(id)sender
{
  self.task.dueDate = [(DatePickerViewController*)sender selectedDate];
  if (![self isNewTask])
  {
    [self save];
  }
}

- (void)checkmarkClicked:(id)sender
{
  self.task.isComplete = !self.task.isComplete;
  [self.task hasBeenUpdated];
  
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSError *error = nil;
  if (![appDelegate.managedObjectContext save:&error])
  {
    NSLog(@"Error saving task: %@ %@", [error description], [error userInfo]);
  }
  
  // Refreshes view to hide/show delete/edit buttons
  [self cancel:YES];
  [self refresh];
}

- (IBAction) deleteTask:(id)sender
{  
  // This happens when deleting completed tasks 
  if (!self.isEditing)
  {
    [self createEditingContext];
  }
  
  if (self.task.key)
  {
    self.task.isDeleted = YES;
    [self.task hasBeenUpdated]; 
  }
  else
  {
    [self.editingContext deleteObject:self.task];
  }
  
  [self save:NO];

  [self hideDeleteTaskConfirmation:self doPop:YES];
}
- (IBAction) askToDeleteTask:(id)sender
{
  UIView *superview = self.navigationController.view;
  
  CGRect frame = superview.frame;
  bgView = [[[UIView alloc] initWithFrame:frame] retain];
  bgView.backgroundColor = [UIColor blackColor];
  bgView.alpha = 0.0;
  [superview addSubview:bgView];
  
  frame = confirmationView.frame;
  frame.origin = CGPointMake(0.0, superview.bounds.size.height);
  confirmationView.frame = frame;
  [superview addSubview:confirmationView];            
  
  // Animate to new location
  [UIView beginAnimations:@"presentWithSuperview" context:nil];
  frame.origin = CGPointMake(0.0, superview.bounds.size.height - confirmationView.bounds.size.height);
  confirmationView.frame = frame;
  bgView.alpha = 0.5;
  [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
  [confirmationView removeFromSuperview];
  [bgView removeFromSuperview];
  [bgView release];
  if ([animationID isEqualToString:@"removeAndPopFromSuperviewWithAnimation"])
  {  
    [self.navigationController popViewControllerAnimated:YES];
  }
}
- (IBAction) cancelDeleteTask:(id)sender
{
  [self hideDeleteTaskConfirmation:sender doPop:NO];
}

- (IBAction) hideDeleteTaskConfirmation:(id)sender doPop:(BOOL)doPopView
{
  if (!doPopView)
  {
    [UIView beginAnimations:@"removeFromSuperviewWithAnimation" context:nil];
  }
  else
  {
    [UIView beginAnimations:@"removeAndPopFromSuperviewWithAnimation" context:nil];
  }
  
  // Set delegate and selector to remove from superview when animation completes
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
  
  // Move this view to bottom of superview
  CGRect frame = confirmationView.frame;
  frame.origin = CGPointMake(0.0, confirmationView.superview.bounds.size.height);
  confirmationView.frame = frame;
  bgView.alpha = 0.0;
  
  [UIView commitAnimations];    
}

- (void)onClickEdit:(id)sender
{
  [self edit:YES];
}

- (void)editingContextDidSave:(NSNotification*)saveNotification
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];	
}

- (void)save
{
  [self save:YES];
}

- (void) save:(BOOL)doRefresh
{
  [self.task hasBeenUpdated];
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self selector:@selector(editingContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.editingContext];
  
  NSError *error;
  if (![self.editingContext save:&error])
  {
    // Update to handle the error appropriately.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }
  [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.editingContext];
  
  if (doRefresh)
  {
    [self refresh];
  }
}

- (void) onClickDone:(id)sender
{
  if (![self isNewTask])
  {
    // Reload task with new updated task
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.task = (Task*)[appDelegate.managedObjectContext objectWithID:[self.task objectID]];
    
    [self cancel:YES];
  }
  else
  {
    [self save];
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
    
    // Reload task with new updated task
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.task = (Task*)[appDelegate.managedObjectContext objectWithID:[self.task objectID]];
  }
  self.editingContext = nil;
}

- (void) onClickCancel:(id)sender
{
  // Only possible with new tasks; can't cancel editing existing tasks
  self.editingContext = nil;
  [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  //return @"Details";
  return nil;
}

- (BOOL)hasProject
{
  return self.isEditing || self.task.project != nil;
}
- (BOOL)hasContexts
{
  return self.isEditing || (self.task.contexts != nil && [self.task.contexts count] > 0);
}
- (BOOL)hasDueDate
{
  return self.isEditing || self.task.dueDate != nil;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{ 
  // Only one section
  return [self hasProject] + [self hasContexts] + [self hasDueDate];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;

  cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"DetailCell"] autorelease];
  }
  
  cell.accessoryType = self.isEditing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
  
  NSUInteger row = [indexPath row];
  
  if ([self hasProject] && row == 0)
  {
    cell.textLabel.text = @"project";
    cell.detailTextLabel.text = self.task.project.name;    
  }
  if ([self hasContexts] && row == [self hasProject])
  {
    cell.textLabel.text = @"contexts";
    cell.detailTextLabel.text = self.task.contextsString;      
  }
  if ([self hasDueDate] && row == [self hasProject] + [self hasContexts])
  {
    cell.textLabel.text = @"due date";
    cell.detailTextLabel.text = self.task.dueString;
  }
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (!self.isEditing)
  {
    return nil;
  }
  
  UIViewController *controller = nil;
  switch ([indexPath row])
  {
    case 0: 
      // Project
      controller = [[[EditProjectPicker alloc] init] autorelease];
      ((EditProjectPicker*)controller).options = [Project projectNames:[self.task managedObjectContext]];
      ((EditProjectPicker*)controller).selected = self.task.project.name;
      ((EditProjectPicker*)controller).target = self;
      ((EditProjectPicker*)controller).saveAction = @selector(saveProject:);
      ((EditProjectPicker*)controller).placeholder = @"New project";
      break;
      
    case 1:
      // Contexts
      controller = [[[EditProjectPicker alloc] init] autorelease];
      ((EditProjectPicker*)controller).appendSelections = YES;
      ((EditProjectPicker*)controller).options = [Context contextNames:[self.task managedObjectContext]];
      ((EditProjectPicker*)controller).selected = [self.task contextsString];
      ((EditProjectPicker*)controller).target = self;
      ((EditProjectPicker*)controller).saveAction = @selector(saveContexts:);
      ((EditProjectPicker*)controller).placeholder = @"@context";
      break;
      
    case 2:
      controller = [[[DatePickerViewController alloc] initWithNibName:@"TaskDatePickerView" bundle:nil] autorelease];
      ((DatePickerViewController*)controller).saveAction = @selector(saveDate:);
      ((DatePickerViewController*)controller).target = self;
      ((DatePickerViewController*)controller).selectedDate = self.task.dueDate;
      break;
  }

  if (controller)
  {
    [self.navigationController pushViewController:controller animated:YES];
  }
  
  return nil;
}


- (void)dealloc
{
  [bodyView release];
  [bodyEditView release];
  [confirmationView release];
  [bgView release];
  
  [topLabel release];
  [topCheckmark release];
  [topButton release];
  [task release];
  [editingContext release];
  
  [super dealloc];
}

@end

