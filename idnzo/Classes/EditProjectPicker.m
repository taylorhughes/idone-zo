//
//  EditProjectPicker.m
//  DNZO
//
//  Created by Taylor Hughes on 5/11/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "EditProjectPicker.h"

@interface EditProjectPicker()
- (void) save:(id)sender;
- (void) delete:(NSString*)string fromSender:(id)sender;
- (void) cancel:(id)sender;
@property (retain, nonatomic) UITextField *textField;
@end

#define FONT_SIZE 17.0
#define TEXT_FIELD_VPADDING 11.0
#define TEXT_FIELD_HPADDING 10.0

@implementation EditProjectPicker

@synthesize options, target, saveAction, deleteAction;
@synthesize appendSelections;
@synthesize textField;
@synthesize title;

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    appendSelections = NO;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.textField release];
    self.textField.delegate = self;
    
    self.textField.textColor = [UIColor blackColor];
    self.textField.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    self.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    
    self.textField.contentMode = UIViewContentModeLeft;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UIBarButtonItem *save   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                           target:self
                                                                           action:@selector(save:)];
  
  UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(cancel:)];
  
  self.navigationItem.rightBarButtonItem = save;
  self.navigationItem.leftBarButtonItem = cancel;
  
  [save release];
  [cancel release];
  
  self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.autoresizesSubviews = YES;
  [self.tableView release];
}

- (BOOL) selectedContains:(NSString*)option
{
  if (self.appendSelections)
  {
    option = [option stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[cd] %@",
                              [NSString stringWithFormat:@".*\\b%@\\b.*", option]];
    return [predicate evaluateWithObject:self.selected];
  }
  else
  {
    return [self.selected isEqualToString:option];
  }
}

- (void)viewWillAppear:(BOOL)animated
{ 
  [super viewWillAppear:animated];

  self.navigationItem.title = self.title;
  if (options)
  {
    for (NSInteger i = 0; i < self.options.count; i++)
    {
      NSString *option = (NSString*)[self.options objectAtIndex:i];
      
      if ([self selectedContains:option])
      {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
        // just scroll to the first one
        break;
      }
    }
  }

  // this needs to come after setting selected to YES
  [self.tableView reloadData];
}

- (NSString*)selected
{
  return self.textField.text;
}
- (void)setSelected:(NSString *)newSelected
{
  self.textField.text = newSelected;
}

- (NSString*)placeholder
{
  return self.textField.placeholder;
}
- (void)setPlaceholder:(NSString*)placeholder
{
  self.textField.placeholder = placeholder;
}


- (void)save:(id)sender
{  
  if (target && saveAction)
  {
    [target performSelector:saveAction withObject:self];
  }
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) delete:(NSString*)string fromSender:(id)sender
{  
  if (target && deleteAction)
  {
    [target performSelector:deleteAction withObject:string withObject:sender];
  }
}

- (void)cancel:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Text view methods

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
  [self.textField resignFirstResponder];
  [self.tableView reloadData];
  return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch(section)
  {
    case 0:
      return 1;
    case 1:
      return [self.options count];
  }
  return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;
  
  switch ([indexPath section])
  {
    case 0:
      cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
      if (cell == nil)
      {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TextViewCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.textField];
        
        CGRect frame = cell.contentView.frame;
        self.textField.frame = CGRectMake(frame.origin.x + TEXT_FIELD_HPADDING, 
                                          frame.origin.y + TEXT_FIELD_VPADDING,
                                          frame.size.width - TEXT_FIELD_HPADDING * 4,
                                          frame.size.height - TEXT_FIELD_VPADDING * 2);
      }
      break;
      
    case 1:
      cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
      if (cell == nil)
      {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NormalCell"] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
      }
      
      cell.textLabel.text = [self.options objectAtIndex:[indexPath row]];
      if ([self selectedContains:cell.textLabel.text])
      {
        cell.textLabel.textColor = DONEZO_SELECTED_TEXT_COLOR;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
      }
      else
      {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
      }
      break;
  }
  
  return cell;
}

- (NSString*) removeOption:(NSString*)option fromSelection:(NSString*)selected
{
  if (self.appendSelections)
  {
    // Replace just this portion of the string.
    NSString *pattern = [NSString stringWithFormat:@"(^|[[:space:]]+)@?%@($|[[:space:]]+)",
                         [option stringByReplacingOccurrencesOfString:@"@" withString:@""]];
    GTMRegex *regex = [GTMRegex regexWithPattern:pattern options:kGTMRegexOptionIgnoreCase];
    selected = [regex stringByReplacingMatchesInString:selected withReplacement:@"\\1"];
    selected = [selected stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];        
  }
  else
  {
    selected = nil;
  }

  return selected;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([indexPath section] == 1)
  {    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *option = cell.textLabel.text;
    NSString *selected = self.selected;

    if ([self selectedContains:option])
    {
      // Remove
      selected = [self removeOption:option fromSelection:selected];
    }
    else
    {
      if (self.appendSelections)
      {
        if (selected != nil && ![selected isEqual:@""])
        {
          selected = [selected stringByAppendingFormat:@" %@", option];
        }
        else
        {
          selected = option;
        }
      }
      else
      {
        selected = option;
      }
    }

    self.selected = selected;
    if (!self.appendSelections) {
      [self save:self];
    }
    
    return indexPath;
  }

  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [indexPath section] == 1 && [self deleteAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle != UITableViewCellEditingStyleDelete)
  {
    return;
  }

  NSString *option = [self.options objectAtIndex:[indexPath row]];

  [self delete:option fromSender:self];

  if ([self selectedContains:option])
  {
    self.selected = [self removeOption:option fromSelection:self.selected];    
  }

  NSMutableArray *mutableOptions = [self.options mutableCopy];
  [mutableOptions removeObjectAtIndex:[indexPath row]];
  self.options = mutableOptions;

  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


- (void)dealloc
{
  [options release];
  [textField release];
  [target release];
  [super dealloc];
}


@end

