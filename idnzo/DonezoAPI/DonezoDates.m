//
//  DonezoDates.m
//  DNZO
//
//  Created by Taylor Hughes on 11/15/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "DonezoDates.h"

@implementation DonezoDates

//
//  Based on:
//  http://developer.apple.com/mac/library/documentation/cocoa/Conceptual/DatesAndTimes/Articles/dtCalendricalCalculations.html#//apple_ref/doc/uid/TP40007836-SW1
//

static NSCalendar *gregorian;

+ (void) initialize
{
  if (self == [DonezoDates class])
  {
    gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] retain];
  }
}

+ (NSDate*) beginningOfThisWeek
{  
  NSDate *today = [[NSDate alloc] init];
  NSDate *beginningOfWeek = nil;
  BOOL ok = [gregorian rangeOfUnit:NSWeekCalendarUnit
                         startDate:&beginningOfWeek
                          interval:NULL
                           forDate:today];
  if (!ok)
  {
    NSLog(@"Could not fetch beginning of week for some reason.");
  }
  
  [today release];
  return beginningOfWeek;
}

+ (NSDate*) endOfThisWeek
{
  NSDate *beginning = [DonezoDates beginningOfThisWeek];  
  NSDateComponents *components = [[NSDateComponents alloc] init];
  
  [components setWeek:1];
  NSDate *end = [gregorian dateByAddingComponents:components toDate:beginning options:0];
  
  [components release];
  
  return end;
}

+ (NSDate*) beginningOfLastWeek
{
  NSDate *beginning = [DonezoDates beginningOfThisWeek];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  
  [components setWeek:-1];
  NSDate *end = [gregorian dateByAddingComponents:components toDate:beginning options:0];
  
  [components release];
  
  return end;
}

+ (NSDate*) thisMorningAtMidnight
{
  NSDate *today = [[NSDate alloc] init];
  NSDate *beginningOfDay = nil;
  BOOL ok = [gregorian rangeOfUnit:NSDayCalendarUnit
                         startDate:&beginningOfDay
                          interval:NULL
                           forDate:today];
  
  if (!ok)
  {
    NSLog(@"Could not fetch beginning of day for some reason.");
  }
  
  return beginningOfDay;
}

+ (NSDate*) tonightAtMidnight
{
  NSDate *beginning = [DonezoDates thisMorningAtMidnight];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  
  [components setDay:1];
  NSDate *end = [gregorian dateByAddingComponents:components toDate:beginning options:0];
  
  [components release];
  
  return end;
}

+ (NSDate*) yesterdayMorningAtMidnight
{
  NSDate *beginning = [DonezoDates thisMorningAtMidnight];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  
  [components setDay:-1];
  NSDate *end = [gregorian dateByAddingComponents:components toDate:beginning options:0];
  
  [components release];
  
  return end;  
}


//                      for dates:        2009-08-03 00:00:00 
#define DONEZO_DATE_INPUT_FORMAT        @"yyyy-MM-dd HH:mm:ss"

#define DONEZO_DATE_OUTPUT_FORMAT       @"MM dd yyyy"
#define DONEZO_DATETIME_OUTPUT_FORMAT   @"yyyy-MM-dd HH:mm:ss"

+ (NSDate*) dateFromDonezoDateString:(NSString*)stringDate
{
  if (stringDate == nil || [stringDate isKindOfClass:[NSNull class]])
  {
    return nil;
  }
  
  NSDate *date = nil;
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  [formatter setDateFormat:DONEZO_DATE_INPUT_FORMAT];
  if ([stringDate rangeOfString:@"."].location == NSNotFound)
  {
    // no precision
    date = [formatter dateFromString:stringDate];
  }
  else
  {
    // NSDateFormatter ***ROUNDS TO MILLISECONDS***; manually add milliseconds instead
    NSArray *datePieces = [stringDate componentsSeparatedByString:@"."];
    stringDate = [datePieces objectAtIndex:0];
    NSTimeInterval interval = [(NSString*)[datePieces objectAtIndex:1] intValue] / 1000000.0;
    interval += [[formatter dateFromString:stringDate] timeIntervalSinceReferenceDate];
    
    date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:interval] autorelease];
  }
  return date;
}

+ (NSString*) donezoDetailedDateStringFromDate:(NSDate*)date
{
  if (date == nil || [date isKindOfClass:[NSNull class]])
  {
    return nil;
  }
  
  // NSDateFormatter ***ROUNDS TO MILLISECONDS IN OUTPUT***; manually add milliseconds instead
  NSTimeInterval interval = [date timeIntervalSinceReferenceDate];
  NSString *microseconds = [[[NSString stringWithFormat:@"%0.6f", interval] componentsSeparatedByString:@"."] objectAtIndex:1];
  
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  [formatter setDateFormat:DONEZO_DATETIME_OUTPUT_FORMAT];
  
  NSString *dateString = [NSString stringWithFormat:@"%@.%@", [formatter stringFromDate:date], microseconds];
  
  return dateString;
}

+ (NSString*) donezoDateStringFromDate:(NSDate*)date
{
  if (date == nil || [date isKindOfClass:[NSNull class]])
  {
    return nil;
  }
  
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  [formatter setDateFormat:DONEZO_DATE_OUTPUT_FORMAT];
  return [formatter stringFromDate:date];  
}

@end
