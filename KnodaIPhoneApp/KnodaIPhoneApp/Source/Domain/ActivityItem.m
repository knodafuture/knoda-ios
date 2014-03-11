//
//  Alert.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ActivityItem.h"

@implementation ActivityItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"activityItemId": @"id",
             @"predictionId": @"prediction_id",
             @"userId" : @"user_id",
             @"creationDate": @"created_at",
             @"predictionBody": @"prediction_body",
             @"type" : @"activity_type"
             };
}


+ (NSValueTransformer *)typeJSONTransformer {
    NSDictionary *states = @{
                             @"EXPIRED": @(ActivityTypeExpired),
                             @"WON": @(ActivityTypeWon),
                             @"LOST": @(ActivityTypeLost),
                             @"COMMENT": @(ActivityTypeComment)
                             };
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}


@end
