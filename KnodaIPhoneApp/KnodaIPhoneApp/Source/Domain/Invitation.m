//
//  Invitation.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/20/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Invitation.h"

@implementation Invitation
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"groupId": @"group_id",
             @"userId": @"recipient_user_id",
             @"email": @"recipient_email",
             @"phoneNumber" : @"recipient_phone"
             };
}
@end
