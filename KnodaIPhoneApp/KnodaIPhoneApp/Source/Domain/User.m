
//
//  NewUser.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "User.h"
#import "SocialAccount.h"

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"id",
             @"avatar": @"avatar_image",
             @"winningPercentage" : @"winning_percentage",
             @"totalPredictions": @"total_predictions",
             @"verifiedAccount" : @"verified_account",
             @"name" : @"username",
             @"socialAccounts" : @"social_accounts"};
}

+ (NSValueTransformer *)avatarJSONTransformer {
    return [self remoteImageTransformer];
}

+ (NSValueTransformer *)socialAccountsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:SocialAccount.class];
}
@end
