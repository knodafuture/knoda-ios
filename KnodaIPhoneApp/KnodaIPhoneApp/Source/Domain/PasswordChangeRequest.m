//
//  PasswordChangeRequest.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "PasswordChangeRequest.h"

@implementation PasswordChangeRequest
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"currentPassword": @"current_password",
             @"password": @"new_password"
             };
}
@end
