//
//  SortViewController.h
//  DNZO
//
//  Created by Taylor Hughes on 10/22/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "DNZOAppDelegate.h"

@interface SortViewController : UITableViewController {
  BOOL descending;
  NSInteger selectedIndex;
}

@property (nonatomic, copy) NSString *sortKey;
@property (nonatomic) BOOL descending;

+ (NSString*)defaultSortKey;
+ (BOOL)isDefaultSort:(NSString*)sortKey;
+ (NSString*)sortedTitleForKey:(NSString*)sortKey;

@end
