//
//  SortViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 10/22/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

@interface SortViewController : UITableViewController {
  BOOL descending;
  NSInteger selectedIndex;
}

@property (nonatomic, readonly) NSString *sortKey;
@property (nonatomic, readonly) BOOL descending;

- (BOOL)isDefaultSort;
- (NSString*)sortedTitle;

@end
