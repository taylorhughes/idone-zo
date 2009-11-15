//
//  TaskCell.m
//  CustomTableViewCell
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "TaskCell.h"

#pragma mark TaskCell implementation

@implementation TaskCell

@synthesize taskCellView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
  {
    CGRect frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    taskCellView = [[TaskCellView alloc] initWithFrame:frame];
    taskCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:taskCellView];
  }
	return self;
}

- (void) displayLocalTask:(Task*)task
{
  [self displayLocalTask:task archived:NO];
}

- (void) displayLocalTask:(Task*)task archived:(BOOL)isArchived
{
  // We could probably use task.isArchived, but that feels wrong
  self.taskCellView.archivedDisplay = isArchived;
  self.taskCellView.isComplete = task.isComplete;
  
  
  self.taskCellView.body = task.body;
  
  NSMutableArray *details = [[NSMutableArray alloc] initWithCapacity:3];
  if (task.project)
  {
    [details addObject:task.project.name];
  }
  if ([task.contexts count] > 0)
  {
    [details addObject:task.contextsString];
  }
  if (task.dueDate)
  {
    [details addObject:task.dueString];
  }
  self.taskCellView.details = details;
  [details release];
  
  [self.taskCellView setNeedsDisplay];
}

- (void) displayRemoteTask:(DonezoTask*)task
{
  self.taskCellView.archivedDisplay = YES;
  
  self.taskCellView.body = task.body; //[@"[remote] " stringByAppendingString:task.body];
  
  NSMutableArray *details = [[NSMutableArray alloc] initWithCapacity:3];
  if (task.project)
  {
    [details addObject:task.project];
  }
  if ([task.contexts count] > 0)
  {
    NSString *contextsString = [@"@" stringByAppendingString:[task.contexts componentsJoinedByString:@" @"]];
    [details addObject:contextsString];
  }
  if (task.dueDate)
  {
    [details addObject:[[Task dueDateFormatter] stringFromDate:task.dueDate]];
  }
  self.taskCellView.details = details;
  [details release];
  
  [self.taskCellView setNeedsDisplay];
}

- (void)dealloc
{
	[taskCellView release];
  [super dealloc];
}

@end
