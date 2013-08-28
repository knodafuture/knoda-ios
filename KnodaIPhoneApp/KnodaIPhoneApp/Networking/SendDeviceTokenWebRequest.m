//
//  SendDeviceTokenWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/27/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SendDeviceTokenWebRequest.h"

@implementation SendDeviceTokenWebRequest


- (id) initWithToken: (NSString*) token
{
    NSDictionary* params = @{@"apple_device_token[token]": token};
    
    self = [super initWithParameters: params];
    return self;
}


- (NSString*) methodName
{
    return @"apple_device_tokens.json";
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (BOOL) requiresAuthToken
{
    return YES;
}


@end
