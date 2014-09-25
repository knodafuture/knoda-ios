
//
//  NewUser.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "User.h"
#import "SocialAccount.h"
#import "NotificationSettings.h"
@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"id",
             @"avatar": @"avatar_image",
             @"winningPercentage" : @"winning_percentage",
             @"verifiedAccount" : @"verified_account",
             @"name" : @"username",
             @"socialAccounts" : @"social_accounts",
             @"createdAt" : @"created_at",
             @"notificationSettings" : @"notification_settings",
             @"followerCount" : @"follower_count",
             @"followingCount" : @"following_count",
             @"followingId" : @"following_id",
             @"rivalry" : @"rivalry"};
}

+ (NSValueTransformer *)avatarJSONTransformer {
    return [self remoteImageTransformer];
}

+ (NSValueTransformer *)socialAccountsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:SocialAccount.class];
}
+ (NSValueTransformer *)notificationSettingsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:NotificationSettings.class];
}

+ (NSValueTransformer *)rivalryJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:Rivalry.class];
}

@end
