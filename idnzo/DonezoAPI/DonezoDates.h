//
//  DonezoDates.h
//  DNZO
//
//  Created by Taylor Hughes on 11/15/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

//
// A container for a variety of date-related stuff.
//
@interface DonezoDates : NSObject {
}

+ (NSDate*) dateFromDonezoDateString:(NSString*)stringDate;
+ (NSString*) donezoDateStringFromDate:(NSDate*)date;
+ (NSString*) donezoDetailedDateStringFromDate:(NSDate*)date;

+ (NSDate*) beginningOfThisWeek;
+ (NSDate*) endOfThisWeek;

+ (NSDate*) beginningOfLastWeek;

+ (NSDate*) thisMorningAtMidnight;
+ (NSDate*) tonightAtMidnight;
+ (NSDate*) yesterdayMorningAtMidnight;

@end
