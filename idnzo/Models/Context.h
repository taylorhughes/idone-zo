//
//  Context.h
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Context :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;

- (NSInteger) compare:(Context*)other;

+ (Context*) findContextWithName:(NSString*)name inContext:(NSManagedObjectContext*)context;
+ (Context*) findOrCreateContextWithName:(NSString*)name inContext:(NSManagedObjectContext*)context;
+ (NSArray*) findOrCreateContextsWithNames:(NSArray*)names inContext:(NSManagedObjectContext*)context;

+ (NSArray*) contexts:(NSManagedObjectContext*)context;
+ (NSArray*) contextNames:(NSManagedObjectContext*)inContext;



@end



