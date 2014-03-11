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
             @"closeDate": @"closed_at",
             @"resolutionDate": @"resolution_date",
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
             @"verifiedACcount" : @"verified_account",
             @"outcome" : @"outcome",
             };
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
