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

@implementation TaskCellView

@synthesize isComplete;
@synthesize body;
@synthesize details;
@synthesize highlighted;
@synthesize archivedDisplay;
@synthesize task;

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
#define ARCHIVED_TEXT_LEFT 7.0

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

- (void)setHighlighted:(BOOL)newHighlighted
{
  if (highlighted != newHighlighted)
  {
    highlighted = newHighlighted;
    [self setNeedsDisplay];
  }
}

- (BOOL)touchedCheckbox:(NSSet *)touches
{
  UITouch *touch = (UITouch*) [[touches allObjects] objectAtIndex:0];
  CGPoint relative = [touch locationInView:self];
  UIImage *image = self.isComplete ? checked : unchecked;
  return (relative.x >= IMAGE_LEFT - TOUCH_BUFFER && relative.x <= IMAGE_LEFT + image.size.width  + TOUCH_BUFFER &&
          relative.y >= IMAGE_TOP  - TOUCH_BUFFER && relative.y <= IMAGE_TOP  + image.size.height + TOUCH_BUFFER);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (![self touchedCheckbox:touches])
  {
    [super touchesBegan:touches withEvent:event]; 
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if ([self touchedCheckbox:touches])
  {
    NSDictionary *info = [NSDictionary dictionaryWithObject:self.task forKey:@"task"];
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc postNotificationName:DonezoShouldToggleCompletedTaskNotification
                       object:self
                     userInfo:info];
  }
  else
  {
    [super touchesEnded:touches withEvent:event];
  }
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
  
  if (!self.archivedDisplay)
  {
    UIImage *image = self.isComplete ? checked : unchecked;
    [image drawInRect:CGRectMake(IMAGE_LEFT, IMAGE_TOP, image.size.width, image.size.height)];    
  }
  
  if (self.isComplete && !self.archivedDisplay)
  {
    [secondaryTextColor set];
  }
  else
  {
    [mainTextColor set];
  }
  
  CGFloat textLeft = self.archivedDisplay ? ARCHIVED_TEXT_LEFT : TEXT_LEFT;
  
  CGFloat width = self.bounds.size.width - textLeft - TEXT_RIGHT_PADDING;
  CGPoint point = CGPointMake(textLeft, MAIN_TEXT_TOP);
  
  [self.body drawAtPoint:point 
                forWidth:width
                withFont:mainFont
             minFontSize:MAIN_TEXT_SIZE
          actualFontSize:nil
           lineBreakMode:UILineBreakModeTailTruncation
      baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
  
  CGSize titleSize = [self.body sizeWithFont:mainFont
                           constrainedToSize:CGSizeMake(width, MAIN_TEXT_SIZE)
                               lineBreakMode:UILineBreakModeTailTruncation];
  
  CGFloat lineTop = MAIN_TEXT_TOP + floor(MAIN_TEXT_SIZE * 0.67);

  // DRAW STRIKETHROUGH
  if (self.isComplete && !self.archivedDisplay)
  {
    UIColor *lineColor = self.isHighlighted ? [UIColor whiteColor] : [UIColor darkGrayColor];
    
    CGContextSetLineWidth(context, LINE_WEIGHT);
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
      
    CGContextMoveToPoint(context, textLeft, lineTop);
    CGContextAddLineToPoint(context, textLeft + titleSize.width, lineTop);
    CGContextStrokePath(context);
  }
    
  // DRAW DETAIL STUFF
  
  
  if (self.details)
  {
    [secondaryTextColor set];
    CGFloat left = textLeft;
    CGFloat detailWidth = (width - [self.details count] * PADDING_BETWEEN_DETAILS) / [self.details count];
    for (NSString *detail in self.details)
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
  } // end if details
}

- (void)dealloc
{
  [body release];
  [details release];
  [super dealloc];
}

@end
