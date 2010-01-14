//
//  TaskViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "TaskViewController.h"

#define FADE_ANIMATION_DURATION 0.2

static UIImage *checked;
static UIImage *unchecked;

@interface TaskViewController ()

@property (nonatomic, retain) NSManagedObjectContext *editingContext;
@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) ConfirmationViewController *confirm;

- (void) loadTask:(Task*)newTask editing:(BOOL)editing;
- (BOOL) isNewTask;

- (void) onClickEdit:(id)sender;
- (void) onClickDone:(id)sender;

- (void) createEditingContext;
- (void) edit:(BOOL)animated;
- (void) cancel:(BOOL)animated;

- (void) editDescription:(BOOL)animated;

- (void) save;
- (void) save:(BOOL)doRefresh;
- (void) save:(BOOL)doRefresh andSync:(BOOL)doSync;

- (void) refresh;
- (void) refreshHeaderAndFooter;

- (BOOL)hasProject;
- (BOOL)hasContexts;
- (BOOL)hasDueDate;

- (void)notifySync;

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
@synthesize confirm;

- (id) init
{
  self = [super init];
  if (self != nil)
  {
    isNewTask = NO;
    isEditing = NO;
    isFirstAppearance = YES;
  }
  return self;
}

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  [topButton addTarget:self action:@selector(onClickEditDescription:) forControlEvents:UIControlEventTouchUpInside];
  [topButton.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
  [topCheckmark addTarget:self action:@selector(checkmarkClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  self.tableView.tableHeaderView = [[[UIView alloc] init] autorelease];
  [self.tableView.tableHeaderView addSubview:bodyView];
  [self.tableView.tableHeaderView addSubview:bodyEditView];
  
  [topLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];  
  
  bottomView.alpha = 0.0;
  [self.tableView addSubview:bottomView];
  
  [self cancel:NO];
  
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self
          selector:@selector(contextDidSave:) 
              name:NSManagedObjectContextDidSaveNotification
            object:nil];
  [dnc addObserver:self
          selector:@selector(donezoDataUpdated:) 
              name:DonezoDataUpdatedNotification
            object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  // This is important because by now self.view has the proper bounds
  [self refresh];
  
  if ([self isNewTask] && isFirstAppearance)
  {
    [self editDescription:NO];
  }
  
  isFirstAppearance = NO;
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
  
  isFirstAppearance = YES;
}

- (void) loadTask:(Task*)newTask editing:(BOOL)editing
{
  [self loadTask:newTask editing:editing positionInList:-1 ofTotalCount:-1];
}

- (void) loadTask:(Task*)newTask editing:(BOOL)editing positionInList:(NSInteger)position ofTotalCount:(NSInteger)total
{
  self.task = newTask;
  
  if (position >= 0 && total > 0)
  {
    self.navigationItem.title = [NSString stringWithFormat:@"Task %d of %d", position + 1, total];
  }
  else
  {
    self.navigationItem.title = @"New Task";
  }
  
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
  
  [self.navigationItem setHidesBackButton:YES animated:animated];  
  
  // insert rows that were not shown previously
  
  NSMutableArray* insertedPaths = [NSMutableArray arrayWithCapacity:3];
  NSMutableArray* updatedPaths = [NSMutableArray arrayWithCapacity:3];
  
  UITableViewRowAnimation animation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
  
  NSInteger existingRows = [self hasProject] + [self hasContexts] + [self hasDueDate];

  // Update all existing rows in the table
  for (NSInteger i = 0; i < existingRows; i++)
  {
    [updatedPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }
  for (NSInteger i = existingRows; i < 3; i++)
  {
    [insertedPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }
  
  isEditing = YES;
  
  [self.tableView beginUpdates];
  
  [self.tableView insertRowsAtIndexPaths:insertedPaths withRowAnimation:animation];
  [self.tableView reloadRowsAtIndexPaths:updatedPaths withRowAnimation:animation];
  
  [self.tableView endUpdates];
    
  if (animated)
  {
    [UIView beginAnimations:@"beginEditing" context:nil];
  }
  
  bodyView.alpha = 0.0;
  bodyEditView.alpha = 1.0;
  if (![self isNewTask])
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
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deletedPaths withRowAnimation:animation];
    [self.tableView reloadRowsAtIndexPaths:updatedPaths withRowAnimation:animation];
    
    [self.tableView endUpdates];
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
  // Adjust for padding on left and right of UITextField
  CGFloat width = topLabel.frame.size.width - 16.0;
  // Resize body cell according to how tall the text is
  CGSize newSize = [self.task.body sizeWithFont:topLabel.font
                              constrainedToSize:CGSizeMake(width, 300.0f)
                                  lineBreakMode:UILineBreakModeWordWrap];
  
  CGFloat newHeight = newSize.height >= topLabel.font.pointSize ? newSize.height : topLabel.font.pointSize;
  // Adjust for the amount of built-in padding on top and bottom of the UITextView
  newHeight += 30.0;
  CGFloat heightDiff = newHeight - topLabel.frame.size.height;
  
  // NOTE: We don't reset the heights here, we just add the *difference* in the height.
  topLabel.frame = CGRectMake(topLabel.frame.origin.x,
                              topLabel.frame.origin.y,
                              topLabel.frame.size.width,
                              newHeight);
  bodyView.frame = CGRectMake(bodyView.frame.origin.x,
                              bodyView.frame.origin.y,
                              bodyView.frame.size.width,
                              bodyView.frame.size.height + heightDiff);
  
  width = topButton.frame.size.width - topButton.contentEdgeInsets.left - topButton.contentEdgeInsets.right;
  newSize = [self.task.body sizeWithFont:topButton.titleLabel.font
                       constrainedToSize:CGSizeMake(width, 300.0f)
                           lineBreakMode:UILineBreakModeWordWrap];
  
  newHeight = newSize.height >= topButton.titleLabel.font.pointSize ? newSize.height : topButton.titleLabel.font.pointSize;
  // Adjust for the amount of built-in padding on top and bottom of the button
  newHeight += 24.0;
  heightDiff = newHeight - topButton.frame.size.height;
  topButton.frame = CGRectMake(topButton.frame.origin.x,
                               topButton.frame.origin.y,
                               topButton.frame.size.width,
                               newHeight);
  bodyEditView.frame = CGRectMake(bodyEditView.frame.origin.x,
                                  bodyEditView.frame.origin.y,
                                  bodyEditView.frame.size.width,
                                  bodyEditView.frame.size.height + heightDiff);
  
  topLabel.text = self.task.body;
  [topButton setTitle:self.task.body forState:UIControlStateNormal];
  
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

- (void)onClickEditDescription:(id)sender
{
  [self editDescription:YES];
}

- (void)editDescription:(BOOL)animated
{
  TextViewController *controller = [[TextViewController alloc] init];
  controller.textView.font = [UIFont systemFontOfSize:17.0f];
  controller.text = self.task.body;
  controller.target = self; 
  controller.saveAction = @selector(saveDescription:);
  controller.cancelAction = @selector(cancelDescription:);
  
  if ([self isNewTask])
  {
    controller.title = @"New Task";
  }
  else
  {
    controller.title = @"Task";
  }

  
  [self.navigationController pushViewController:controller animated:animated];
  [controller release];
}

- (void)saveDescription:(id)sender
{
  self.task.body = [(TextViewController*)sender text];
  [self save];
  
  // pops the textviewcontroller
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelDescription:(id)sender
{
  // If this is a new task and we haven't saved the body, cancel and dismiss the modal controller
  if ([self isNewTask] && self.task.body == nil)
  {
    self.editingContext = nil;
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
  }
  else
  {
    // pops the textviewcontroller
    [self.navigationController popViewControllerAnimated:YES];  
  }
}

- (void) saveProject:(id)sender
{
  NSString *newProject = [(EditProjectPicker*)sender selected];
  
  self.task.project = [Project findOrCreateProjectWithName:newProject inContext:[self.task managedObjectContext]];
  [self save];
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
  [self save];
}
- (void)saveDate:(id)sender
{
  self.task.dueDate = [(DatePickerViewController*)sender selectedDate];
  [self save];
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
  
  [self notifySync];
  
  // Refreshes view to hide/show delete/edit buttons
  [self cancel:YES];
  [self refresh];
}


- (IBAction) askToDeleteTask:(id)sender
{
  UIView *superview = self.navigationController.view;
  
  self.confirm = [ConfirmationViewController confirmationViewWithSuperview:superview];
  
  [self.confirm.confirmButton setTitle:@"Delete Task" forState:UIControlStateNormal];
  [self.confirm.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
  
  self.confirm.target = self;
  self.confirm.confirmAction = @selector(deleteTask);
  // This is overwritten by deleteTask() if the task is deleted
  self.confirm.afterHideAction = @selector(cleanupConfirmation);
  
  [self.confirm show];
}

- (void) cleanupConfirmation
{
  self.confirm = nil;
}
- (void) deleteTask
{  
  // This happens when deleting completed tasks 
  if (!self.isEditing)
  {
    [self createEditingContext];
  }
  
  if (self.task.key)
  {
    self.task.isDeleted = YES;
    [self save:NO];
  }
  else
  {
    // This task was not saved remotely, so we don't need to sync it.
    [self.editingContext deleteObject:self.task];
    [self save:NO andSync:NO];
  }  

  self.confirm.afterHideAction = @selector(finishDeletingTask);
}
- (void) finishDeletingTask
{ 
  [self.navigationController popViewControllerAnimated:YES];
  self.editingContext = nil;
  self.task = nil;
  
  [self cleanupConfirmation];
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

- (void)contextDidSave:(NSNotification*)saveNotification
{
  [self performSelectorOnMainThread:@selector(updateEditingContextWithChangesFromMainContext:)
                         withObject:saveNotification
                      waitUntilDone:YES];
}
- (void)updateEditingContextWithChangesFromMainContext:(id)obj
{
  if (self.editingContext != nil)
  {
    NSLog(@"Refreshing editing context with changes from main context...");
    NSNotification* saveNotification = (NSNotification*)obj;
    [self.editingContext mergeChangesFromContextDidSaveNotification:saveNotification];
  }
}

- (void) donezoDataUpdated:(NSNotification*)notification
{
  if ([self.view window])
  {
    NSLog(@"Handling updated data in TaskViewController.");
    [self refresh];
  }
}

- (void)save
{
  [self save:YES];
}

- (void) save:(BOOL)doRefresh
{
  [self save:doRefresh andSync:YES];
}

- (void) save:(BOOL)doRefresh andSync:(BOOL)doSync
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
  
  if (doSync)
  {
    [self notifySync];
  }
  
  if (doRefresh)
  {
    [self refresh];
  }
}



- (void) notifySync
{
  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  
  [dnc postNotificationName:DonezoDataUpdatedNotification object:self];
  
  NSDictionary *info = [NSDictionary dictionaryWithObject:self.task.taskList forKey:@"list"];
  [dnc postNotificationName:DonezoShouldSyncNotification object:self userInfo:info];    
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
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
    
    // Reload task with new updated task
    DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.task = (Task*)[appDelegate.managedObjectContext objectWithID:[self.task objectID]];
  }
  self.editingContext = nil;
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
  return 1;
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
  return [self hasProject] + [self hasContexts] + [self hasDueDate];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger row = [indexPath row];
  
  NSString *textLabel = nil;
  NSString *detailLabel = nil;

  if ([self hasProject] && row == 0)
  {
    if (self.task.project != nil)
    {
      textLabel = @"project";
      detailLabel = self.task.project.name;
    }
    else
    {
      textLabel = @"add project";
    }
  }
  if ([self hasContexts] && row == [self hasProject])
  {
    if ([self.task.contexts count] > 0)
    {
      textLabel = @"contexts";
      detailLabel = self.task.contextsString;
    }
    else
    {
      textLabel = @"add contexts";
    }
  }
  if ([self hasDueDate] && row == [self hasProject] + [self hasContexts])
  {
    if (self.task.dueDate != nil)
    {
      textLabel = @"due date";
      detailLabel = self.task.dueString;
    }
    else
    {
      textLabel = @"add due date";
    }
  }
  
  NSString *identifier = nil;
  if (detailLabel == nil)
  {
    identifier = @"DetailCellLeft";
  }
  else
  {
    identifier = @"DetailCellRight";
  }
  
  AdjustableTextLabelWidthCell *cell = (AdjustableTextLabelWidthCell*)[self.tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil)
  {
    cell = [[[AdjustableTextLabelWidthCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier] autorelease];
  } 
  cell.accessoryType = self.isEditing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
  
  if (detailLabel)
  {
    cell.textLabel.text = textLabel;
    cell.detailTextLabel.text = detailLabel;
  }
  else
  {
    // Setting this to an empty string is required to fix a rendering issue in iPhoneOS 3.1.2
    cell.detailTextLabel.text = @"";
    cell.autoresizesSubviews = YES;
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.textLabelWidth = 150.0;
    cell.textLabel.text = textLabel;
  }
  
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (!self.isEditing)
  {
    NSObject *filteredObject = nil;
    if ([self hasProject] && [indexPath row] == 0)
    {
      filteredObject = self.task.project;
    }
    else if ([self hasContexts] && [indexPath row] == [self hasProject])
    {
      filteredObject = [[self.task.contexts allObjects] objectAtIndex:0];
    }
    else if ([self hasDueDate] && [indexPath row] == [self hasProject] + [self hasContexts])
    {
      filteredObject = self.task.dueDate;
    }
    
    NSDictionary *info = [NSDictionary dictionaryWithObject:filteredObject forKey:@"filteredObject"];
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc postNotificationName:DonezoShouldFilterListNotification
                       object:self
                     userInfo:info];
    
    [self.navigationController popViewControllerAnimated:YES];
  }
  else
  {
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
        ((EditProjectPicker*)controller).placeholder = @"New Project";
        ((EditProjectPicker*)controller).title = @"Project";
        break;
        
      case 1:
        // Contexts
        controller = [[[EditProjectPicker alloc] init] autorelease];
        ((EditProjectPicker*)controller).appendSelections = YES;
        ((EditProjectPicker*)controller).options = [Context contextNames:[self.task managedObjectContext]];
        ((EditProjectPicker*)controller).selected = [self.task contextsString];
        ((EditProjectPicker*)controller).target = self;
        ((EditProjectPicker*)controller).saveAction = @selector(saveContexts:);
        ((EditProjectPicker*)controller).placeholder = @"@home @work";
        ((EditProjectPicker*)controller).title = @"Contexts";
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
  }
  
  return nil;
}

- (void)dealloc
{
  [bodyView release];
  [bodyEditView release];
  
  [topLabel release];
  [topCheckmark release];
  [topButton release];
  [task release];
  [editingContext release];
  
  [super dealloc];
}

@end

