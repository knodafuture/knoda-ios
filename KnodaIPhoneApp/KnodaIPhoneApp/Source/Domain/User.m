
//
//  NewUser.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"id",
             @"avatar": @"avatar_image",
             @"winningPercentage" : @"winning_percentage",
             @"totalPredictions": @"total_predictions",
             @"verifiedAccount" : @"verified_account",
             @"name" : @"username"};
}

+ (NSValueTransformer *)avatarJSONTransformer {
    return [self remoteImageTransformer];
}
@end
