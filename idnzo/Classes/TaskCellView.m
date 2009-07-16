//
//  TaskCellView.m
//  DNZO
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskCellView.h"

static UIImage *unchecked;
static UIImage *checked;

@interface TaskCellView()
- (NSArray *)getDetails;
@end

@implementation TaskCellView

@synthesize task, wasCompleted;

#define PADDING 10.0
#define IMAGE_WIDTH 15.0
#define IMAGE_HEIGHT 20.0
#define IMAGE_TOP 10.0
#define IMAGE_LEFT 10.0
#define MAIN_FONT_SIZE 20.0
#define SECONDARY_FONT_SIZE 14.0
#define TOUCH_BUFFER 10.0

+ (void) initialize
{
  if (self == [TaskCellView class])
  {
    checked = [[UIImage imageNamed:@"checked.png"] retain];
    unchecked = [[UIImage imageNamed:@"unchecked.png"] retain];
  }
}

+ (NSInteger) height
{
  return PADDING + MAIN_FONT_SIZE + PADDING + SECONDARY_FONT_SIZE + PADDING;
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame])
  {
		self.opaque = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.multipleTouchEnabled = YES;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = (UITouch*) [[touches allObjects] objectAtIndex:0];
  CGPoint relative = [touch locationInView:self];
  if (relative.x >= IMAGE_LEFT - TOUCH_BUFFER && relative.x <= IMAGE_LEFT + IMAGE_WIDTH  + TOUCH_BUFFER &&
      relative.y >= IMAGE_TOP  - TOUCH_BUFFER && relative.y <= IMAGE_TOP  + IMAGE_HEIGHT + TOUCH_BUFFER)
  {
    // hit the checkbox
    self.wasCompleted = YES;
  }
  
  [super touchesBegan:touches withEvent:event];
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
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Color and font for the main text items (time zone name, time)
	UIColor *mainTextColor = [UIColor blackColor];
	UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
  
	// Color and font for the secondary text items (GMT offset, day)
	UIColor *secondaryTextColor = [UIColor darkGrayColor];
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
  
  UIImage *image;
  if (task.complete)
  {
    image = checked;
  }
  else
  {
    image = unchecked;
  }
  [image drawInRect:CGRectMake(IMAGE_LEFT, IMAGE_TOP, image.size.width, image.size.height)];
  
  if (self.task.complete)
  {
    [secondaryTextColor set];
  }
  else
  {
    [mainTextColor set];
  }

  CGFloat left  = IMAGE_LEFT + IMAGE_WIDTH + PADDING;
  
  CGFloat width = self.bounds.size.width - left - PADDING;
  CGPoint point = CGPointMake(left, PADDING);
  
  [self.task.body drawAtPoint:point 
                     forWidth:width
                     withFont:mainFont
                  minFontSize:MAIN_FONT_SIZE
               actualFontSize:NULL
                lineBreakMode:UILineBreakModeTailTruncation
           baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
  
  CGSize titleSize = [self.task.body sizeWithFont:mainFont constrainedToSize:CGSizeMake(width, MAIN_FONT_SIZE) lineBreakMode:UILineBreakModeTailTruncation];
  CGFloat lineTop = PADDING + floor(MAIN_FONT_SIZE * 0.67);

  // DRAW STRIKETHROUGH
  if (self.task.complete)
  {
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [[UIColor darkGrayColor] CGColor]);
      
    CGContextMoveToPoint(context, left, lineTop);
    CGContextAddLineToPoint(context, left + titleSize.width, lineTop);
    CGContextStrokePath(context);
  }
    
  // DRAW DETAIL STUFF
  
  [secondaryTextColor set];
  
  NSArray *details = [self getDetails];
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
