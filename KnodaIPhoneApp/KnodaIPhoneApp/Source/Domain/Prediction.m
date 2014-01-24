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
@implementation Prediction

+ (NSString *)responseKey {
    return @"predictions";
}


+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    Prediction *prediction = [super instanceFromDictionary:dictionary];
    
    
    prediction.predictionId = [dictionary[@"id"] integerValue];
    prediction.body = dictionary[@"body"];
    prediction.agreeCount = [dictionary[@"agreed_count"] integerValue];
    prediction.disagreeCount = [dictionary[@"disagreed_count"] integerValue];
    prediction.votedUsersCount = [dictionary[@"market_size"] integerValue];
    prediction.expired = [dictionary[@"expired"] boolValue];
    prediction.isReadyForResolution = [dictionary[@"is_ready_for_resolution"] boolValue];
    prediction.settled = [dictionary[@"settled"] boolValue];
    prediction.userId = [dictionary[@"user_id"] integerValue];
    prediction.userName = dictionary[@"username"];
    prediction.commentCount = [dictionary[@"comment_count"] integerValue];
    prediction.shortUrl = dictionary[@"short_url"];
    prediction.verifiedAccount = [dictionary[@"verified_account"] boolValue];
    
    id obj = dictionary[@"tags"];
    if ([obj isKindOfClass:[NSArray class]] && [obj count])
        prediction.category = [[obj objectAtIndex: 0] objectForKey: @"name"];
    
    obj = dictionary[@"user_avatar"];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        prediction.thumbAvatarUrl = obj[@"thumb"];
        prediction.smallAvatarUrl = obj[@"small"];
        prediction.largeAvatarUrl = obj[@"big"];
    }
    
    obj = dictionary[@"outcome"];
    if (obj && ![obj isKindOfClass: [NSNull class]])
        prediction.outcome = [obj boolValue];
    
    prediction.creationDate   = [prediction dateFromObject:dictionary[@"created_at"]];
    prediction.expirationDate = [prediction dateFromObject:dictionary[@"expires_at"]];
    prediction.resolutionDate = [prediction dateFromObject:dictionary[@"resolution_date"]];
    
    obj = dictionary[@"my_challenge"];
    
    if ([obj isKindOfClass:NSDictionary.class])
        prediction.challenge = [Challenge instanceFromDictionary:obj];
    
    obj = dictionary[@"my_points"];
    
    if ([obj isKindOfClass:NSDictionary.class]) {
        prediction.challenge.basePoints = [obj[@"base_points"] integerValue];
        prediction.challenge.marketSizePoints = [obj[@"market_size_points"] integerValue];
        prediction.challenge.outcomePoints = [obj[@"outcome_points"] integerValue];
        prediction.challenge.predictionMarketPoints = [obj[@"prediction_market_points"] integerValue];
    }
    
    return prediction;
}

- (void)setOutcome:(BOOL)outcome {
    _outcome = outcome;
    self.hasOutcome = YES;
}

- (NSDictionary *)parametersDictionary {
    NSDateComponents *dc = [self.expirationDate gmtDateComponents];
    NSDateComponents *rdc = [self.resolutionDate gmtDateComponents];
    return @{@"prediction[body]" : self.body,
             @"prediction[expires_at(1i)]" : @(dc.year),
             @"prediction[expires_at(2i)]" : @(dc.month),
             @"prediction[expires_at(3i)]" : @(dc.day),
             @"prediction[expires_at(4i)]" : @(dc.hour),
             @"prediction[expires_at(5i)]" : @(dc.minute),
             @"prediction[resolution_date(1i)" : @(rdc.year),
             @"prediction[resolution_date(2i)" : @(rdc.month),
             @"prediction[resolution_date(3i)" : @(rdc.day),
             @"prediction[resolution_date(4i)" : @(rdc.hour),
             @"prediction[resolution_date(5i)" : @(rdc.minute),
             @"prediction[tag_list][]" : self.category};
}

@end
