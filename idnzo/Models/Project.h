//
//  Project.h
//  DNZO
//
//  Created by Taylor Hughes on 7/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Project :  NSManagedObject  
{
}

+ (NSArray*) projectNames:(NSManagedObjectContext*)context;
+ (Project*) findProjectWithName:(NSString*)name inContext:(NSManagedObjectContext*)context;

@property (nonatomic, retain) NSString * name;

@end



