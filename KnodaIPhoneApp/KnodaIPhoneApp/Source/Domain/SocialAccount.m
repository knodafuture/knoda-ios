//
//  SocialSignInRequest.m
//  KnodaIPhoneApp
//
//  Created by nick on 4/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SocialAccount.h"

@implementation SocialAccount
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"providerName": @"provider_name",
             @"providerId" : @"provider_id",
             @"providerAccountName" : @"provider_account_name",
             @"accessToken" : @"access_token",
             @"accessTokenSecret" : @"access_token_secret",
             @"socialAccountId" : @"id",
             @"userId" : @"user_id"
             };
}
@end
