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
#import "RemoteImage.h"
#import "Challenge.h"

NSString *responseDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z";

@implementation WebObject

+ (id)instanceFromData:(NSData *)data {
    id jsonObject = [data jsonObject];
    
    if (!jsonObject || ![jsonObject isKindOfClass:NSDictionary.class])
        return nil;
    
    NSError *error;
    
    id object = [MTLJSONAdapter modelOfClass:self.class fromJSONDictionary:jsonObject error:&error];
    
    if (error)
        return nil;
    
    return object;
}


+ (NSArray *)arrayFromData:(NSData *)data {
    
    id jsonObject = [data jsonObject];
    
    if (!jsonObject || ![jsonObject isKindOfClass:NSArray.class])
        return nil;
    
    NSArray *array = jsonObject;

    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    
    for (NSDictionary *object in array) {
        if (![object isKindOfClass:NSDictionary.class])
            continue;
        
        NSError *error;
        id serializedObject = [MTLJSONAdapter modelOfClass:self.class fromJSONDictionary:object error:&error];
        
        if (serializedObject && !error)
            [returnArray addObject:serializedObject];
    }
    
    return [NSArray arrayWithArray:returnArray];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return nil;
}

+ (NSValueTransformer *)remoteImageTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:RemoteImage.class];
}

+ (NSValueTransformer *)challengeTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:Challenge.class];
}

+ (NSValueTransformer *)boolTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id value) {
                if (!value)
                    return @NO;
                return value;
            } reverseBlock:^id(id boolValue) {
                return [boolValue boolValue] ? @YES : @NO;
            }];
}

+ (NSValueTransformer *)dateTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self dateFromObject:str];
    } reverseBlock:^(NSDate *date) {
        return [date stringWithFormat:responseDateFormat];
    }];
}

+ (NSDate *)dateFromObject:(id)obj {
    if (obj && ![obj isKindOfClass: [NSNull class]] && [obj isKindOfClass:[NSString class]])
        return [NSDate dateFromString:obj withFormat:responseDateFormat];
    return nil;
}

+ (NSValueTransformer *)creationDateJSONTransformer {
    return [self dateTransformer];
}

+ (NSData *)dataFromArrayOfWebObjects:(NSArray *)objects {
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:objects.count];
    
    for (WebObject *object in objects) {
        NSDictionary *dictionary = [MTLJSONAdapter JSONDictionaryFromModel:object];
        [result addObject:dictionary];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return data;
    
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *modifiedDictionaryValue = [[super dictionaryValue] mutableCopy];
    
    for (NSString *originalKey in [super dictionaryValue]) {
        if ([self valueForKey:originalKey] == nil) {
            [modifiedDictionaryValue removeObjectForKey:originalKey];
        }
    }
    
    return [modifiedDictionaryValue copy];
}

@end
