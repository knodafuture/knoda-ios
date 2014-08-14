//
//  NewPrediction.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Prediction.h"
#import "Challenge.h"    
#import "NSDate+Utils.h"
#import "PredictionPoints.h"

@implementation Prediction

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"predictionId": @"id",
             @"creationDate": @"created_at",
             @"expirationDate" : @"expires_at",
             @"resolutionDate" : @"resolution_date",
             @"closeDate": @"closed_at",
             @"shortUrl": @"short_url",
             @"agreeCount" : @"agreed_count",
             @"disagreeCount": @"disagreed_count",
             @"commentCount": @"comment_count",
             @"userId": @"user_id",
             @"userAvatar" : @"user_avatar",
             @"isReadyForResolution": @"is_ready_for_resolution",
             @"challenge": @"my_challenge",
             @"points": @"my_points",
             @"categories" : @"tags",
             @"verifiedAccount" : @"verified_account",
             @"outcome" : @"outcome",
             @"groupId" : @"group_id",
             @"groupName" : @"group_name",
             @"expirationString" : @"expired_text",
             @"creationString" : @"predicted_text",
             @"contestId" : @"contest_id",
             @"contestName" : @"contest_name"
             };
}
+ (NSValueTransformer *)groupIdJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id value) {
        if (!value)
            return @(0);
        return value;
    } reverseBlock:^id(NSValue *value) {
        int final = 0;
        [value getValue:&final];
        if (final == 0)
            return nil;
        return value;
    }];
}

+ (NSValueTransformer *)outcomeJSONTransformer {
    return [self boolTransformer];
}

+ (NSValueTransformer *)expirationDateJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)closeDateJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)resolutionDateJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)challengeJSONTransformer {
    return [self challengeTransformer];
}

+ (NSValueTransformer *)userAvatarJSONTransformer {
    return [self remoteImageTransformer];
}

+ (NSValueTransformer *)pointsJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PredictionPoints.class];

}
@end
