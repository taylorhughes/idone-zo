//
//  SortViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 10/22/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

@interface SortViewController : UITableViewController {
  BOOL descending;
  NSInteger selectedIndex;
}

@property (nonatomic, readonly) NSSortDescriptor *sorter;

- (BOOL)isDefaultSort;
- (NSString*)sortedTitle;

@end
