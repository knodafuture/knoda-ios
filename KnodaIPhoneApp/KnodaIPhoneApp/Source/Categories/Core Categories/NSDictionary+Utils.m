//
//  NSDictionary+Utils.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 14.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NSDictionary+Utils.h"

@implementation NSDictionary (Utils)

- (NSString *)stringForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if([obj isKindOfClass:[NSString class]]) {
        return obj;
    } else {
        DLog(@"can't get string for key: %@", key);
    }
    return @"";
}

@end
