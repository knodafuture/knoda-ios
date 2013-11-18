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
    BOOL sandbox = NO;
    
#ifdef DEBUG
    sandbox = YES;
#endif
    
    NSDictionary* params = @{@"apple_device_token[token]": token, @"apple_device_token[sandbox]": (sandbox) ? @"true" : @"false"};
    
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


- (void) fillResultObject: (id) parsedResult
{
    self.tokenID = [parsedResult  objectForKey: @"id"];
}


@end
