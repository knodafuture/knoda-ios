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

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    
    LoginResponse *response = [super instanceFromDictionary:dictionary];
    
    response.email = dictionary[@"email"];
    response.token = dictionary[@"auth_token"];
    
    return response;
    
}


@end
