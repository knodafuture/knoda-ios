//
//  Member.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Member.h"

@implementation Member
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"memberId": @"id",
             @"groupId": @"groupId",
             @"userId" : @"user_id"
             };
}


+ (NSValueTransformer *)roleJSONTransformer {
    NSDictionary *states = @{
                             @"OWNER": @(MembershipTypeOwner),
                             @"MEMBER": @(MembershipTypeMember)};
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}

@end
