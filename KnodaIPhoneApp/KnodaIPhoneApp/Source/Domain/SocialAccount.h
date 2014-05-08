//
//  SocialSignInRequest.h
//  KnodaIPhoneApp
//
//  Created by nick on 4/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface SocialAccount : WebObject
@property (strong, nonatomic) NSNumber *socialAccountId;
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *providerName;
@property (strong, nonatomic) NSString *providerId;
@property (strong, nonatomic) NSString *providerAccountName;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *accessTokenSecret;
@end
