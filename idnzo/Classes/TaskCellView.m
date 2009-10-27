//
//  TaskCellView.m
//  DNZO
//
//  Created by Taylor Hughes on 5/15/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
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

// horizontal space between project / context / date
#define PADDING_BETWEEN_DETAILS 5.0

// Image has 5px of transparency to the left and top of the box
#define IMAGE_TOP 2.0
#define IMAGE_LEFT 2.0

// buffer around the image in pixels that will count as hitting the checkmark
#define TOUCH_BUFFER 10.0

#define MAIN_TEXT_TOP 3.0
#define MAIN_TEXT_SIZE 18.0

#define SECONDARY_TEXT_TOP 26.0
#define SECONDARY_TEXT_SIZE 14.0

#define TEXT_LEFT 32.0
#define TEXT_RIGHT_PADDING 10.0
#define CELL_HEIGHT 46.0

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
  return CELL_HEIGHT;
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
  UIImage *image = task.isComplete ? checked : unchecked;
  if (relative.x >= IMAGE_LEFT - TOUCH_BUFFER && relative.x <= IMAGE_LEFT + image.size.width  + TOUCH_BUFFER &&
      relative.y >= IMAGE_TOP  - TOUCH_BUFFER && relative.y <= IMAGE_TOP  + image.size.height + TOUCH_BUFFER)
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
	UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_TEXT_SIZE];
  
	// Color and font for the details text
	UIColor *secondaryTextColor = self.isHighlighted ? [UIColor whiteColor] : [UIColor darkGrayColor];
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_TEXT_SIZE];
  
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
  
  CGFloat width = self.bounds.size.width - TEXT_LEFT - TEXT_RIGHT_PADDING;
  CGPoint point = CGPointMake(TEXT_LEFT, MAIN_TEXT_TOP);
  
  [self.task.body drawAtPoint:point 
                     forWidth:width
                     withFont:mainFont
                  minFontSize:MAIN_TEXT_SIZE
               actualFontSize:nil
                lineBreakMode:UILineBreakModeTailTruncation
           baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
  
  CGSize titleSize = [self.task.body sizeWithFont:mainFont
                                constrainedToSize:CGSizeMake(width, MAIN_TEXT_SIZE)
                                    lineBreakMode:UILineBreakModeTailTruncation];
  
  CGFloat lineTop = MAIN_TEXT_TOP + floor(MAIN_TEXT_SIZE * 0.67);

  // DRAW STRIKETHROUGH
  if (task.isComplete)
  {
    UIColor *lineColor = self.isHighlighted ? [UIColor whiteColor] : [UIColor darkGrayColor];
    
    CGContextSetLineWidth(context, LINE_WEIGHT);
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
      
    CGContextMoveToPoint(context, TEXT_LEFT, lineTop);
    CGContextAddLineToPoint(context, TEXT_LEFT + titleSize.width, lineTop);
    CGContextStrokePath(context);
  }
    
  // DRAW DETAIL STUFF
  
  [secondaryTextColor set];
  
  NSArray *details = [self getDetails];
  CGFloat left = TEXT_LEFT;
  CGFloat detailWidth = (width - [details count] * PADDING_BETWEEN_DETAILS) / [details count];
  for (NSString *detail in details)
  {
    point = CGPointMake(left, SECONDARY_TEXT_TOP);
    
    CGSize size = [detail sizeWithFont:secondaryFont
                     constrainedToSize:CGSizeMake(detailWidth, SECONDARY_TEXT_SIZE)
                         lineBreakMode:UILineBreakModeTailTruncation];
    
    [detail drawAtPoint:point 
               forWidth:size.width
               withFont:secondaryFont
            minFontSize:SECONDARY_TEXT_SIZE
         actualFontSize:nil
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
