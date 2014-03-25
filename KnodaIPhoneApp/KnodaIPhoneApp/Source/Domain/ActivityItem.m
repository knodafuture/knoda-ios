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
             @"creationDate": @"created_at",
             @"type" : @"activity_type"
             };
}


+ (NSValueTransformer *)typeJSONTransformer {
    NSDictionary *states = @{
                             @"EXPIRED": @(ActivityTypeExpired),
                             @"WON": @(ActivityTypeWon),
                             @"LOST": @(ActivityTypeLost),
                             @"COMMENT": @(ActivityTypeComment),
                             @"INVITATION" : @(ActivityTypeInvitation)
                             };
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}



@end
