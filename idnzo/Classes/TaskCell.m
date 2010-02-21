//
//  TaskCell.m
//  CustomTableViewCell
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "TaskCell.h"

#pragma mark TaskCell implementation

@interface TaskCell (Private)

- (void) manuallyAnimateTransitionIfNeeded;
- (void) handleInterimTransitionUpdate:(id)userInfo;

@end

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
    
    // Keep things in the top left when stuff gets resized
    self.contentView.contentMode = UIViewContentModeTopLeft;
    taskCellView.contentMode = UIViewContentModeTopLeft;
    // Don't stretch anything
    taskCellView.contentStretch = CGRectZero;
    
    contentViewTransitionTimer = nil;
    contentViewBeginFrame = CGRectZero;
    contentViewEndFrame = CGRectZero;
    isAboutToTransition = NO;
    isTransitioning = NO;
  }
  return self;
}




- (void) aboutToTransition
{
  @synchronized(self)
  {
    if (isTransitioning) { return; }
    
    contentViewBeginFrame = taskCellView.frame;
  }
}
#define TIMER_INTERVAL 0.02f
#define TIMER_DURATION 0.25f
#define MAX_LOOPS 100
- (void) manuallyAnimateTransitionIfNeeded
{
  @synchronized(self)
  {
    if (isTransitioning || CGRectEqualToRect(contentViewBeginFrame, CGRectZero)) { return; }
    contentViewEndFrame = taskCellView.frame;
    if (contentViewBeginFrame.size.width == contentViewEndFrame.size.width) { return; }
    
    taskCellView.frame = contentViewBeginFrame;
    
    isTransitioning = YES;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"loops"];
    contentViewTransitionTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                                  target:self
                                                                selector:@selector(handleInterimTransitionUpdate:)
                                                                userInfo:userInfo
                                                                 repeats:YES];
    [contentViewTransitionTimer retain];
  }
}
- (void) handleInterimTransitionUpdate:(id)sender
{ 
  CGFloat difference = (TIMER_INTERVAL / TIMER_DURATION) * (contentViewEndFrame.size.width - contentViewBeginFrame.size.width);
  CGFloat newWidth = taskCellView.frame.size.width + difference;
  
  // This is load bearing: This contentView size might be different now from when we started
  CGFloat endWidth = self.contentView.frame.size.width;
  
  NSMutableDictionary *userInfo = [contentViewTransitionTimer userInfo]; 
  NSInteger numLoops = [[userInfo objectForKey:@"loops"] intValue];
  
  if (difference > 0 && newWidth >= endWidth ||
      difference < 0 && newWidth <= endWidth ||
      numLoops > MAX_LOOPS)
  {
    if (numLoops > MAX_LOOPS)
    {
      NSLog(@"Exceeded the maximum number of loops for this transition! Something is awry.");
    }
    
    newWidth = endWidth;
    
    @synchronized(self)
    {
      isTransitioning = NO;
      contentViewBeginFrame = CGRectZero;
      contentViewEndFrame = CGRectZero;
      
      [contentViewTransitionTimer invalidate];
      [contentViewTransitionTimer release];
      contentViewTransitionTimer = nil;
    }
  }
  
  // Set up this variable such that if this shit ever goes haywire it stops it.
  [userInfo setValue:[NSNumber numberWithInt:(numLoops + 1)] forKey:@"loops"];
  
  taskCellView.frame = CGRectMake(taskCellView.frame.origin.x, 
                                  taskCellView.frame.origin.y, 
                                  newWidth,
                                  taskCellView.frame.size.height);
  [taskCellView setNeedsDisplay];
}

- (void) layoutSubviews
{
  [super layoutSubviews];
  
  [self manuallyAnimateTransitionIfNeeded];
}

- (void) willTransitionToState:(UITableViewCellStateMask)state
{
  [self aboutToTransition];
  
  [super willTransitionToState:state];
  
  [self manuallyAnimateTransitionIfNeeded];
}




- (void) displayLocalTask:(Task*)task
{
  [self displayLocalTask:task archived:NO];
}

- (void) displayLocalTask:(Task*)task archived:(BOOL)isArchived
{
  self.taskCellView.task = task;
  
  // We could probably use task.isArchived, but that feels wrong
  self.taskCellView.archivedDisplay = isArchived;
  self.taskCellView.isComplete = task.isComplete;
  
  self.taskCellView.body = task.body;
  
  NSMutableArray *details = [[NSMutableArray alloc] initWithCapacity:4];
  if (isArchived)
  {
    [details addObject:[task.taskList name]];
  }
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
  self.taskCellView.task = nil;
  
  self.taskCellView.archivedDisplay = YES;
  
  self.taskCellView.body = task.body; //[@"[remote] " stringByAppendingString:task.body];
  
  NSMutableArray *details = [[NSMutableArray alloc] initWithCapacity:4];
  if (task.taskListName)
  {
    [details addObject:task.taskListName];
  }
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
  [contentViewTransitionTimer release];
  [super dealloc];
}

@end
