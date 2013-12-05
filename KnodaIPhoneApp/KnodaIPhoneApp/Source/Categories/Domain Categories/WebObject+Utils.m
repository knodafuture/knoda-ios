//
//  WebObject+Utils.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject+Utils.h"
#import "NSData+Utils.h"

@implementation WebObject (Utils)

+ (NSArray *)arrayOfNamesFromChallengesData:(NSData *)data {
    
    NSDictionary *dictionary = [data jsonObject];
    
    if (!dictionary || ![dictionary isKindOfClass:NSDictionary.class])
        return nil;
    
    NSArray *challenges = dictionary[@"challenges"];
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:challenges.count];
    
    for (NSDictionary *user in challenges) {
        id name = user[@"username"];
        
        if (name && [name isKindOfClass:NSString.class])
            [result addObject:name];
    }
    
    return [NSArray arrayWithArray:result];
}

@end
