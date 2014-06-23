//
//  Settings.m
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/20/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Settings.h"
#import "NotificationSettings.h"

@implementation Settings
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"settings" : @"settings"
             };
}

+ (NSValueTransformer *)settingsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:NotificationSettings.class];
}
@end
