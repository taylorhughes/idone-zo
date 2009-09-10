//
//  TaskViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"

static UIImage *checked;
static UIImage *unchecked;

@interface TaskViewController ()

@property (nonatomic, retain) NSManagedObjectContext *editingContext;
@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) Task *uneditedTask;

- (void) edit:(id)sender;
- (void) save:(id)sender;
- (void) cancel:(id)sender;
- (void) refresh;

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

@synthesize task, uneditedTask;
@synthesize editingContext;
@synthesize isEditing;

- (id) init
{
  self = [super init];
  if (self != nil)
  {

  }
  return self;
}

- (void) viewDidLoad
{
  [super viewDidLoad];  
  if (topLabel == nil)
  {
    topLabel = [[[UILabel alloc] init] retain];
    topLabel.lineBreakMode = UILineBreakModeWordWrap;
    topLabel.numberOfLines = 0;
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.font = [UIFont boldSystemFontOfSize:20.0];
    
    topButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    topButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    topButton.titleLabel.numberOfLines = 1;
    topButton.titleLabel.font = topLabel.font;
    topButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    topButton.contentEdgeInsets = UIEdgeInsetsMake(0,10.0f,0,10.0f);
    [topButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [topButton addTarget:self action:@selector(editNameClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    topCheckmark = [[[UIImageView alloc] init] retain];
    topCheckmark.frame = CGRectMake(5.0f, 10.0f, 30.0f, 30.0f);
    topCheckmark.contentMode = UIViewContentModeCenter;
    
    self.tableView.tableHeaderView = [[[UIView alloc] init] autorelease];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    
    [self.tableView.tableHeaderView addSubview:topLabel];
    [self.tableView.tableHeaderView addSubview:topButton];
    [self.tableView.tableHeaderView addSubview:topCheckmark];
  }
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  // This is important because by now self.view has the proper bounds
  [self refresh];
}

- (void) loadEditingWithNewTaskForList:(TaskList*)list
{
  [self loadTask:nil editing:YES];
  self.task.taskList = (TaskList*)[self.editingContext objectWithID:[list objectID]];
}

- (void) loadTask:(Task*)newTask editing:(BOOL)editing
{
  self.task = newTask;
  self.uneditedTask = newTask;
  
  if (isEditing && !editing)
  {
    // cancel edit
    [self cancel:self];
  }
  else if (!isEditing && editing)
  {
    // begin edit
    [self edit:self];
  }
}

- (void) refresh
{
  if (self.isEditing)
  {
    // Change the buttons
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                          target:self
                                                                          action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = save;
    [save release];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancel;
    [cancel release];    
  }
  else
  {
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                          target:self
                                                                          action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = edit;
    [edit release];
    
    self.navigationItem.leftBarButtonItem = nil;
  }
  
  topCheckmark.image = self.task.isComplete ? checked : unchecked;
  
  //bodyCell.accessoryType = self.isEditing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
  
  // Resize body cell according to how tall the text is
  CGFloat leftPadding = 10.0f;
  CGFloat checkWidth = topCheckmark.frame.size.width + leftPadding;
  CGRect viewRect = [self.view frame];
  CGSize size = [self.task.body sizeWithFont:topLabel.font
                           constrainedToSize:CGSizeMake(viewRect.size.width - checkWidth - leftPadding, 200.0f)
                               lineBreakMode:UILineBreakModeWordWrap];
  
  CGFloat topPadding = 12.0f;
  CGFloat height = size.height < 40.0f ? 40.0f : size.height;
  CGFloat totalWidth = viewRect.size.width;
  
  topLabel.hidden = self.isEditing;
  topButton.hidden = !self.isEditing;

  topLabel.text = self.task.body;
  topLabel.frame = CGRectMake(checkWidth, topPadding, totalWidth - checkWidth - leftPadding, height);
  
  [topButton setTitle:self.task.body forState:UIControlStateNormal];
  topButton.frame = topLabel.frame; //CGRectMake(checkWidth, topPadding, viewRect.size.width - checkWidth, size.height + leftPadding * 2);
    
  self.tableView.tableHeaderView.frame = CGRectMake(0.0f, 0.0f, totalWidth, topPadding + height);
  self.tableView.tableHeaderView = self.tableView.tableHeaderView;
  
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
}

- (void)editNameSaved:(id)sender
{
  self.task.body = [(TextFieldController*)sender text];
  [self refresh];
}

- (void)edit:(id)sender
{
  isEditing = YES;
  [self refresh];
  
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
  
  /*
  // load editing view into modal view
  UINavigationController *modalNavigationController = [EditViewController navigationControllerWithTask:editingTask
                                                                                         dismissTarget:self  
                                                                                            saveAction:@selector(editTaskSaved)
                                                                                          cancelAction:@selector(editTaskCanceled)];
  
  [self.navigationController presentModalViewController:modalNavigationController animated:YES];
  */
}

- (void)editingContextDidSave:(NSNotification*)saveNotification
{
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];	
}

- (void) save:(id)sender
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
  
  self.editingContext = nil;
  
  // Reload task with new updated task
  DNZOAppDelegate *appDelegate = (DNZOAppDelegate *)[[UIApplication sharedApplication] delegate];
  self.task = (Task*)[appDelegate.managedObjectContext objectWithID:[self.task objectID]];
    
  if (self.uneditedTask != nil)
  {
    self.uneditedTask = self.task;
    isEditing = NO;
    [self refresh];
  }
  else
  {    
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
  }
}

- (void) cancel:(id)sender
{
  if (self.uneditedTask != nil)
  {
    self.task = self.uneditedTask;
    self.editingContext = nil;
    
    isEditing = NO;
    [self refresh];
  }
  else 
  {
    [self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
  }
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

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
  return 3;
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
  
  switch ([indexPath row])
  {
    case 0:
      cell.textLabel.text = @"project";
      cell.detailTextLabel.text = self.task.project.name;
      break;
    case 1:
      cell.textLabel.text = @"contexts";
      cell.detailTextLabel.text = self.task.contextsString;
      break;
    case 2:
      cell.textLabel.text = @"due date";
      cell.detailTextLabel.text = self.task.dueString;
      break;
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


- (void)dealloc
{
  [topLabel release];
  [topCheckmark release];
  [topButton release];
  [task release];
  [uneditedTask release];
  [editingContext release];
  
  [super dealloc];
}

@end

