//
//  ChangePasswordRequest.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/21/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ChangePasswordRequest.h"

@implementation ChangePasswordRequest

- (id) initWithCurrentPassword : (NSString*) currentPassword newPassword : (NSString *) newPassword {
    NSDictionary* theParameters = @{@"current_password" : currentPassword, @"new_password" : newPassword};

    self = [super initWithParameters: theParameters];
    return self;
}

- (NSString*) methodName
{
    return @"password.json";
}

- (NSString*) httpMethod
{
    return @"PUT";
}

- (void) fillResultObject: (id) parsedResult
{

}

@end
