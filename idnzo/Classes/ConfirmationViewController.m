//
//  ConfirmationViewController.m
//  DNZO
//
//  Created by Taylor Hughes on 11/20/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "ConfirmationViewController.h"

#define ANIMATION_HIDE_CONFIRMATION @"hideConfirmationViewAnimation"

@interface ConfirmationViewController (Private)

- (void) hide;

@end



@implementation ConfirmationViewController

@synthesize superview;
@synthesize bgView;

@synthesize confirmButton, cancelButton;

@synthesize target;
@synthesize confirmAction, cancelAction, afterHideAction;

+ (ConfirmationViewController*)confirmationViewWithSuperview:(UIView*)superview
{
  ConfirmationViewController *controller = [[[ConfirmationViewController alloc] 
                                             initWithNibName:@"ConfirmationView"
                                             bundle:nil] autorelease];
  
  // Accessing this variable should force the nib to load.
  controller.view;
  controller.superview = superview;
  
  return controller;
}

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  [self.confirmButton.titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
}

- (void) show
{
  CGRect frame = self.superview.frame;
  self.bgView = [[[UIView alloc] initWithFrame:frame] autorelease];
  self.bgView.backgroundColor = [UIColor blackColor];
  self.bgView.alpha = 0.0;
  [self.superview addSubview:bgView];
  
  frame = self.view.frame;
  frame.origin = CGPointMake(0.0, self.superview.bounds.size.height);
  self.view.frame = frame;
  [self.superview addSubview:self.view];            
  
  // Animate to new location
  [UIView beginAnimations:@"presentWithSuperview" context:nil];
  frame.origin = CGPointMake(0.0, self.superview.bounds.size.height - self.view.bounds.size.height);
  self.view.frame = frame;
  self.bgView.alpha = 0.5;
  [UIView commitAnimations];
}

- (void) hide
{
  [UIView beginAnimations:ANIMATION_HIDE_CONFIRMATION context:nil];
  
  // Set delegate and selector to remove from superview when animation completes
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
  
  // Move this view to bottom of superview
  CGRect frame = self.view.frame;
  frame.origin = CGPointMake(0.0, self.superview.bounds.size.height);
  self.view.frame = frame;
  self.bgView.alpha = 0.0;
  
  [UIView commitAnimations];    
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
  [self.view removeFromSuperview];
  [self.bgView removeFromSuperview];
  self.bgView = nil;
  
  if (self.target && self.afterHideAction)
  {
    [self.target performSelector:self.afterHideAction]; 
  }
}

- (IBAction) confirm:(id)sender
{
  if (self.target && self.confirmAction)
  {
    [self.target performSelector:self.confirmAction];
  }
  
  [self hide];
}
- (IBAction) cancel:(id)sender
{
  if (self.target && self.cancelAction)
  {
    [self.target performSelector:self.cancelAction];
  }
  
  [self hide];  
}

- (void)dealloc
{
  [superview release];
  [bgView release];
  
  [confirmButton release];
  [cancelButton release];
  
  [super dealloc];
}


@end

