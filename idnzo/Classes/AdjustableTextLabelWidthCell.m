//
//  AdjustableTextLabelWidthCell.m
//  DNZO
//
//  Created by Taylor Hughes on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AdjustableTextLabelWidthCell.h"

@implementation AdjustableTextLabelWidthCell

@synthesize textLabelWidth;

- (void) layoutSubviews
{
  [super layoutSubviews];
  
  if (textLabelWidth > 0)
  {
    CGRect newframe = self.textLabel.frame;
    newframe.size = CGSizeMake(textLabelWidth,self.textLabel.frame.size.height);
    self.textLabel.frame = newframe;
  }
}

@end
