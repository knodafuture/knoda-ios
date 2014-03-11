//
//  Comment.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Comment.h"
#import "Challenge.h"

@implementation Comment

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"commentId": @"id",
             @"creationDate": @"created_at",
             @"userId": @"user_id",
             @"userAvatar": @"user_avatar",
             @"predictionId": @"prediction_id",
             @"verifiedAccount" : @"verified_account",
             @"body": @"text"
             };
}

+ (NSValueTransformer *)challengeJSONTransformer {
    return [self challengeTransformer];
}

+ (NSValueTransformer *)userAvatarJSONTransformer {
    return [self remoteImageTransformer];
}

@end
