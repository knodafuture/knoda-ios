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
             @"predictionBody": @"prediction_body"
             };
}

@end
