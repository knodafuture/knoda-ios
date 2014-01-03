//
//  WebObject.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebObject.h"
#import "NSData+Utils.h"
#import "NSDate+Utils.h"

NSString *ResponseDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'zzz";

@implementation WebObject

+ (id)instanceFromData:(NSData *)data {
    return [self instanceFromDictionary:[data jsonObject]];
}

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    
    if (![dictionary isKindOfClass:NSDictionary.class])
        return nil;
    
    return [[self alloc] init];
    
}

+ (NSString *)responseKey {
    return nil;
}


+ (NSArray *)arrayFromData:(NSData *)data {
    
    id jsonObject = [data jsonObject];
    
    if (!jsonObject)
        return nil;
    
    if ([jsonObject isKindOfClass:NSDictionary.class] && ![self responseKey]) {
        NSLog(@"Expecting dictionary with response key = %@, aborting serialization", [self responseKey]);
        return nil;
    }
    
    NSArray *array;
    
    if ([jsonObject isKindOfClass:NSArray.class])
        array = jsonObject;
    else if ([jsonObject isKindOfClass:NSDictionary.class] && [self responseKey])
        array = jsonObject[[self responseKey]];

    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    
    for (id object in array) {
        if (![object isKindOfClass:NSDictionary.class])
            continue;
        
        id serializedObject = [self instanceFromDictionary:object];
        
        if (serializedObject)
            [returnArray addObject:serializedObject];
    }
    
    return [NSArray arrayWithArray:returnArray];
}

- (NSDictionary *)parametersDictionary {
    return nil;
}

- (NSDate *)dateFromObject:(id)obj {
    if (obj && ![obj isKindOfClass: [NSNull class]] && [obj isKindOfClass:[NSString class]])
        return [NSDate dateFromString:[obj stringByAppendingString: @"GMT"] withFormat:ResponseDateFormat];
    return nil;
}
@end
