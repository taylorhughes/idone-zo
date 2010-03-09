//
//  TextFieldViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 11/10/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "TextFieldViewController.h"

@interface TextFieldViewController (Private)

- (BOOL) wasPresentedModally;

@end

@implementation TextFieldViewController

@synthesize text, placeholder;
@synthesize textField;

@synthesize target;
@synthesize saveAction, cancelAction;

#define FONT_SIZE 17.0
#define TEXT_FIELD_VPADDING 11.0
#define TEXT_FIELD_HPADDING 10.0
#define TEXT_FIELD_WIDTH_ADJUSTMENT 5.0


+ (TextFieldViewController*) textFieldViewController 
{
  return [[[TextFieldViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
}

- (BOOL) wasPresentedModally
{
  return [[self.navigationController viewControllers] count] == 1;
}

- (id) initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self != nil)
  {
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.textField release];
    self.textField.delegate = self;
    
    self.textField.textColor = [UIColor blackColor];
    self.textField.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    
    self.textField.keyboardType = UIKeyboardTypeDefault;
    self.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.textField.contentMode = UIViewContentModeLeft;
    
    // Should be 67 pixels to be perfectly vertically centered, but that looks weird.
    [self.tableView setContentInset:UIEdgeInsetsMake(58.0f, 0, 0, 0)];
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  UIBarButtonItem *save   = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                           target:self
                                                                           action:@selector(save:)] autorelease];
  
  UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(cancel:)] autorelease];
  
  self.navigationItem.rightBarButtonItem = save;
  self.navigationItem.leftBarButtonItem = cancel;
  
  self.textField.text = self.text;
  self.textField.placeholder = self.placeholder;
  
  self.navigationItem.title = self.title;
}

- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  [textField becomeFirstResponder];
  // Put the cursor at the end
  //textField.selectedRange = NSMakeRange(textField.text.length, 0);
}

- (void) cancel:(id)sender
{
  if (self.target && self.cancelAction)
  {
    [self.target performSelector:self.cancelAction withObject:self];
  }
  
  if ([self wasPresentedModally])
  {
    [self.navigationController dismissModalViewControllerAnimated:YES];
  }
  else
  {
    [self.navigationController popViewControllerAnimated:YES];
  }
}
- (void) save:(id)sender
{
  self.text = textField.text;
  
  if (self.target && self.saveAction)
  {
    [self.target performSelector:self.saveAction withObject:self];
  }
  
  if ([self wasPresentedModally])
  {
    [self.navigationController dismissModalViewControllerAnimated:YES];
  }
  else
  {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
  //[self.textField resignFirstResponder];
  //[self.tableView reloadData];
  //return YES;
  return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;
  
  cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TextViewCell"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.textField];
    
    CGRect frame = cell.contentView.frame;
    self.textField.frame = CGRectMake(frame.origin.x + TEXT_FIELD_HPADDING, 
                                      frame.origin.y + TEXT_FIELD_VPADDING,
                                      frame.size.width - TEXT_FIELD_HPADDING * 3 - TEXT_FIELD_WIDTH_ADJUSTMENT,
                                      frame.size.height - TEXT_FIELD_VPADDING * 2);
  }
  
  return cell;
}


- (void) dealloc
{
  [text release];
  [placeholder release];
  [textField release];
  [target release];
  
  [super dealloc];
}

@end
