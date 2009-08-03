//
//  TextViewCell.m
//  DNZO
//
//  Created by Taylor Hughes on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#define CELL_PADDING 10.0

#import "TextViewCell.h"

@implementation TextViewCell

@synthesize view;

- (id)initWithFrame:(CGRect)aRect reuseIdentifier:(NSString *)identifier
{
	self = [super initWithFrame:aRect reuseIdentifier:identifier];
	if (self)
	{
		// turn off selection use
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void)setView:(UIView *)inView
{
	view = inView;
	[self.view retain];
	[self.contentView addSubview:inView];
	[self layoutSubviews];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	
	// inset the text view within the cell
	if (contentRect.size.width > (CELL_PADDING*2))	// but not if the width is too small
	{
		self.view.frame  = CGRectMake(contentRect.origin.x + CELL_PADDING,
                                  contentRect.origin.y + CELL_PADDING,
                                  contentRect.size.width - (CELL_PADDING * 2),
                                  contentRect.size.height - (CELL_PADDING * 2));
	}
}

- (void)dealloc
{
  [view release];
  [super dealloc];
}

@end