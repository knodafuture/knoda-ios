//
//  InvitationCodeDetails.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/27/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "InvitationCodeDetails.h"
#import "Group.h"

@implementation InvitationCodeDetails
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"invitationId": @"id",
             @"link": @"invitation_link"
             };
}

+ (NSValueTransformer *)groupJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:Group.class];
}

@end
