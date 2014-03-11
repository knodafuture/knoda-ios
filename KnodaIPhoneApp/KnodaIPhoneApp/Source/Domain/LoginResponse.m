//
//  LoginResponse.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoginResponse.h"

const NSString *LoginResponseKey = @"LoginResponse";

@implementation LoginResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"token" : @"auth_token"};
}

@end
