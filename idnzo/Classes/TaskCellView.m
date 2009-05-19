//
//  TaskCellView.m
//  DNZO
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskCellView.h"

@interface TaskCellView()
- (NSArray *)getDetails;
@end

@implementation TaskCellView

@synthesize task;

#define PADDING 10.0
#define MAIN_FONT_SIZE 20.0
#define SECONDARY_FONT_SIZE 14.0

+ (NSInteger) height
{
  return PADDING + MAIN_FONT_SIZE + PADDING + SECONDARY_FONT_SIZE + PADDING;
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
		self.opaque = YES;
    self.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)setTask:(Task*)newTask
{
  if (task)
  {
    [task release];
  }
  task = [newTask retain];
	[self setNeedsDisplay];
}

- (NSArray*)getDetails
{
  NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
  if (task.project)
  {
    [array addObject:task.project.name];
  }
  if (task.contexts && [task.contexts count] > 0)
  {
    [array addObject:task.contextsString];
  }
  if (task.due)
  {
    [array addObject:task.dueString];
  }
  
  if ([array count] == 0)
  {
    [array addObject:@"(none)"];
  }
  return array;
}

- (void)drawRect:(CGRect)rect
{  
	// Color and font for the main text items (time zone name, time)
	UIColor *mainTextColor = [UIColor blackColor];
	UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
  
	// Color and font for the secondary text items (GMT offset, day)
	UIColor *secondaryTextColor = [UIColor darkGrayColor];
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
  
  [mainTextColor set];

  CGFloat width = self.bounds.size.width - 2 * PADDING;
  CGPoint point = CGPointMake(PADDING, PADDING);
  
  [self.task.body drawAtPoint:point 
                     forWidth:width
                     withFont:mainFont
                  minFontSize:MAIN_FONT_SIZE
               actualFontSize:NULL
                lineBreakMode:UILineBreakModeTailTruncation
           baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
  
  [secondaryTextColor set];
  
  NSArray *details = [self getDetails];
  CGFloat left = PADDING;
  CGFloat detailWidth = (width - [details count] * PADDING) / [details count];
  for (NSString *detail in details)
  {
    point = CGPointMake(left, PADDING * 2 + MAIN_FONT_SIZE);
    
    CGSize size = [detail sizeWithFont:secondaryFont constrainedToSize:CGSizeMake(detailWidth, SECONDARY_FONT_SIZE) lineBreakMode:UILineBreakModeTailTruncation];
    //CGFloat realWidth = size.width < detailWidth ? size.width : detailWidth;
    
    [detail drawAtPoint:point 
               forWidth:size.width
               withFont:secondaryFont
            minFontSize:SECONDARY_FONT_SIZE
         actualFontSize:NULL
          lineBreakMode:UILineBreakModeTailTruncation
     baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
    left += size.width + PADDING;
  }
}


- (void)dealloc
{
  [task release];
  [super dealloc];
}

@end
