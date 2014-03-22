//
//  Group.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Group.h"

@implementation Group
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"groupId": @"id",
             @"groupDescription": @"description",
             @"rank": @"my_info.rank",
             @"leader" : @"leader_info",
             @"memberCount" : @"member_count",
             @"avatar" : @"avatar_image",
             @"shareUrl" : @"share_url"
    };
}

+ (NSValueTransformer *)leaderJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:Leader.class];
}

+ (NSValueTransformer *)avatarJSONTransformer {
    return [super remoteImageTransformer];
}
@end
