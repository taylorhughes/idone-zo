//
//  HyperlinksTest.m
//  DNZO
//
//  Created by Taylor Hughes on 12/17/09.
//  Copyright 2009 Two-Stitch Software. All rights reserved.
//

#import "HyperlinksTest.h"


@implementation HyperlinksTest

static NSArray *stringsLinks;

+ (void) setUp
{
  stringsLinks =  [[NSArray alloc] initWithObjects:
                   
                   @"A string with text http://taylor-hughes.com/",
                   [NSArray arrayWithObject:@"http://taylor-hughes.com/"],
                   
                   @"done-zo.com/: string with text", 
                   [NSArray arrayWithObject:@"http://done-zo.com/"],
                   
                   @"String: tdawg.co.uk text!", 
                   [NSArray arrayWithObject:@"http://tdawg.co.uk"],
                   
                   @"(String: https://done-zo.com/l/tasks/?query=text) text!",
                   [NSArray arrayWithObject:@"https://done-zo.com/l/tasks/?query=text"],
                   
                   @"String: tdawg.co.uk text! zoobaru.zot.zoop done-zo.com/l/t?query=text", 
                   [NSArray arrayWithObjects:@"http://tdawg.co.uk", @"http://done-zo.com/l/t?query=text", nil],
                   
                   nil];
}

- (void) testHyperlinksDetected
{
  for (NSInteger i = 0; i < [stringsLinks count]; i += 2)
  {
    NSString *string = [stringsLinks objectAtIndex:i];
    NSArray *links   = [stringsLinks objectAtIndex:i+1];
    
    AHHyperlinkScanner *scanner = [[AHHyperlinkScanner alloc] initWithString:string usingStrictChecking:NO];
    NSArray *uris = [scanner allURIs];
    
    for (NSInteger j = 0; j < [links count]; j++)
    {
      NSURL *url = [(AHMarkedHyperlink*)[uris objectAtIndex:j] URL];
      NSLog(@"Detected %@", url);
      STAssertEqualObjects([NSURL URLWithString:[links objectAtIndex:j]], url,
                            @"NSURL differs from object found. %@ %@", [links objectAtIndex:j], url);
    }
  }
}


@end
