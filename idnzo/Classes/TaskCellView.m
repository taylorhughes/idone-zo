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
@synthesize highlighted;

#define PADDING 2.0
#define PADDING_BETWEEN_DETAILS PADDING * 3

#define IMAGE_WIDTH 26.0
#define IMAGE_HEIGHT 20.0
#define IMAGE_TOP 0.0
#define IMAGE_LEFT 0.0
#define TOUCH_BUFFER 10.0

#define MAIN_FONT_OFFSET 2.0
#define MAIN_FONT_SIZE 18.0
#define SECONDARY_FONT_SIZE 14.0

#define LINE_WEIGHT  1.0

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
  return PADDING + MAIN_FONT_SIZE + PADDING + SECONDARY_FONT_SIZE + PADDING * 4;
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

- (void)setHighlighted:(BOOL)newHighlighted
{
  if (highlighted != newHighlighted)
  {
    highlighted = newHighlighted;
    [self setNeedsDisplay];
  }
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
  if (task.dueDate)
  {
    [array addObject:task.dueString];
  }
  
  return array;
}

- (void)drawRect:(CGRect)rect
{ 
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Color and font for the task body text
	UIColor *mainTextColor = self.isHighlighted ? [UIColor whiteColor] : [UIColor blackColor];
	UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
  
	// Color and font for the details text
	UIColor *secondaryTextColor = self.isHighlighted ? [UIColor whiteColor] : [UIColor darkGrayColor];
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
  
  UIImage *image = task.isComplete ? checked : unchecked;
  [image drawInRect:CGRectMake(IMAGE_LEFT, IMAGE_TOP, image.size.width, image.size.height)];
  
  if (task.isComplete)
  {
    [secondaryTextColor set];
  }
  else
  {
    [mainTextColor set];
  }

  CGFloat left  = IMAGE_LEFT + IMAGE_WIDTH + PADDING;
  
  CGFloat width = self.bounds.size.width - left - PADDING;
  CGPoint point = CGPointMake(left, PADDING + MAIN_FONT_OFFSET);
  
  [self.task.body drawAtPoint:point 
                     forWidth:width
                     withFont:mainFont
                  minFontSize:MAIN_FONT_SIZE
               actualFontSize:nil
                lineBreakMode:UILineBreakModeTailTruncation
           baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
  
  CGSize titleSize = [self.task.body sizeWithFont:mainFont constrainedToSize:CGSizeMake(width, MAIN_FONT_SIZE) lineBreakMode:UILineBreakModeTailTruncation];
  CGFloat lineTop = PADDING + floor(MAIN_FONT_SIZE * 0.67 + MAIN_FONT_OFFSET);

  // DRAW STRIKETHROUGH
  if (task.isComplete)
  {
    UIColor *lineColor = self.isHighlighted ? [UIColor whiteColor] : [UIColor darkGrayColor];
    
    CGContextSetLineWidth(context, LINE_WEIGHT);
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
      
    CGContextMoveToPoint(context, left, lineTop);
    CGContextAddLineToPoint(context, left + titleSize.width, lineTop);
    CGContextStrokePath(context);
  }
    
  // DRAW DETAIL STUFF
  
  [secondaryTextColor set];
  
  NSArray *details = [self getDetails];
  CGFloat detailWidth = (width - [details count] * PADDING) / [details count];
  CGFloat detailTop = PADDING * 2 + MAIN_FONT_SIZE + MAIN_FONT_OFFSET;
  for (NSString *detail in details)
  {
    point = CGPointMake(left, detailTop);
    
    CGSize size = [detail sizeWithFont:secondaryFont constrainedToSize:CGSizeMake(detailWidth, SECONDARY_FONT_SIZE) lineBreakMode:UILineBreakModeTailTruncation];
    //CGFloat realWidth = size.width < detailWidth ? size.width : detailWidth;
    
    [detail drawAtPoint:point 
               forWidth:size.width
               withFont:secondaryFont
            minFontSize:SECONDARY_FONT_SIZE
         actualFontSize:NULL
          lineBreakMode:UILineBreakModeTailTruncation
     baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
    left += size.width + PADDING_BETWEEN_DETAILS;
  }
}

- (void)dealloc
{
  [task release];
  [super dealloc];
}

@end
