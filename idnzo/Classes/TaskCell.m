//
//  TaskCell.m
//  CustomTableViewCell
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskCell.h"

#pragma mark TaskCell implementation

@implementation TaskCell

@synthesize task;

- (void)setTask:(Task *)newTask
{
  if (task)
  {
    [task release];
  }
  task = [newTask retain];
  taskCellView.task = task;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
  {
    CGRect frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    taskCellView = [[TaskCellView alloc] initWithFrame:frame];
    taskCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:taskCellView];
  }
	return self;
}

- (void)dealloc {
  [task release];
	[taskCellView release];
  [super dealloc];
}

@end
