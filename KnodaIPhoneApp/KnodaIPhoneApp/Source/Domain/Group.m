//
//  Group.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Group.h"
#import "Member.h"
NSString *ActiveGroupChangedNotificationName = @"ACTIVEGROUPNOTIFICATION";
NSString *ActiveGroupNotificationKey = @"ACTIVEGROUP";

@implementation Group
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"groupId": @"id",
             @"groupDescription": @"description",
             @"rank": @"my_info.rank",
             @"leader" : @"leader_info",
             @"memberCount" : @"member_count",
             @"avatar" : @"avatar_image",
             @"shareUrl" : @"share_url",
             @"myMembership" : @"my_membership",
             @"ownerId" : @"owner"
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

+ (NSValueTransformer *)avatarJSONTransformer {
    return [super remoteImageTransformer];
}

+ (NSValueTransformer *)myMembershipJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:Member.class];
}
@end
