//
//  Contest.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Contest.h"
#import "Leader.h"
#import "ContestStage.h"

@implementation Contest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contestId": @"id",
             @"name": @"name",
             @"description": @"description",
             @"detailsUrl" : @"detail_url",
             @"image" : @"avatar_image",
             @"contestStages" : @"contest_stages",
             @"leader" : @"leader_info",
             @"rank" : @"my_info.rank",
             @"participants" : @"participants"
             };
}

+ (NSValueTransformer *)leaderJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:Leader.class];
}

+ (NSValueTransformer *)rankJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id value) {
        if (!value)
            return @(0);
        return value;
    } reverseBlock:^id(id value) {
        return value;
    }];
}

+ (NSValueTransformer *)imageJSONTransformer {
    return [super remoteImageTransformer];
}

+ (NSValueTransformer *)contestStagesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:ContestStage.class];
}

@end
