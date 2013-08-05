//
//  CategoriesWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CategoriesWebRequest.h"

@implementation CategoriesWebRequest


- (NSString*) methodName
{
    return @"topics.json";
}


- (NSString*) httpMethod
{
    return @"GET";
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Get Categories Result: %@", parsedResult);
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: 0];
    NSArray* topics = [parsedResult objectForKey: @"topics"];
    
    for (NSDictionary* topic in topics)
    {
        [array addObject: [topic objectForKey: @"name"]];
    }
    
    self.categories = [NSArray arrayWithArray: array];
}


@end
