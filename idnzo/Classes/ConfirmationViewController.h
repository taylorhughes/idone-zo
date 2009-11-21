//
//  ConfirmationViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 11/20/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

@interface ConfirmationViewController : UIViewController {
  // This is the view we cover up with this confirmation view.
  UIView *superview;
  // This is the blackout layer that appears behind the confirmation dialog
  UIView *bgView;
  
  UIButton *confirmButton;
  UIButton *cancelButton;
  
  NSObject *target;
  
  SEL confirmAction;
  SEL cancelAction;
  SEL afterHideAction;
}

@property (nonatomic, retain) IBOutlet UIView   *superview;
@property (nonatomic, retain) IBOutlet UIView   *bgView;

@property (nonatomic, retain) IBOutlet UIButton *confirmButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

@property (nonatomic, retain) NSObject *target;
@property (nonatomic) SEL confirmAction;
@property (nonatomic) SEL cancelAction;
@property (nonatomic) SEL afterHideAction;

+ (ConfirmationViewController*)confirmationViewWithSuperview:(UIView*)superview;

- (void) show;

- (IBAction) confirm:(id)sender;
- (IBAction) cancel:(id)sender;

@end
