//
//  NotificationSettings.m
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NotificationSettings.h"

@implementation NotificationSettings
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"Id": @"id",
             @"setting" : @"setting",
             @"displayName" : @"display_name",
             @"description" : @"description",
             @"active" : @"active"
             };
}

@end
