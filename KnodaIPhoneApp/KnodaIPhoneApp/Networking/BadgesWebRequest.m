//
//  BadgesWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BadgesWebRequest.h"

@implementation BadgesWebRequest

- (NSString*) methodName
{
    return @"badges.json";
}
- (BOOL) requiresAuthToken
{
    return YES;
}

- (void) fillResultObject: (id) parsedResult
{
    if ([parsedResult respondsToSelector:@selector(valueForKey:)]) {
        self.badgesImagesArray = [[NSMutableArray alloc]init];
        [[parsedResult valueForKey:@"badges"]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.badgesImagesArray addObject:[UIImage imageNamed:[obj valueForKey:@"name"]]];
        }];
    }
}

@end
