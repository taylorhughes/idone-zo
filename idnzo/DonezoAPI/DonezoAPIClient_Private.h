//
//  DonezoAPIClient_Private.h
//
//  Created by Taylor Hughes on 10/5/09.
//

@interface DonezoAPIClient ()

@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, readonly) NSString *apiUrl;

- (BOOL)login:(NSError**)error;

- (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key error:(NSError**)error;
- (NSObject*)getObjectFromPath:(NSString*)path withKey:(NSString*)key usingMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error;

- (NSString*)responseFromRequestToPath:(NSString*)path withMethod:(NSString*)method andBody:(NSString*)body error:(NSError**)error;

- (NSDictionary*)parseDonezoResponse:(NSString*)responseString error:(NSError**)error;

@end