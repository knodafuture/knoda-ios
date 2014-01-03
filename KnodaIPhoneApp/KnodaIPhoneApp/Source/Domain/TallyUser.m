//
//  TallyUser.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/3/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "TallyUser.h"

@implementation TallyUser


+ (NSString *)responseKey {
    return @"challenges";
}

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    TallyUser *user = [super instanceFromDictionary:dictionary];
    
    if (!user)
        return nil;
    
    user.agree = [dictionary[@"agree"] boolValue];
    user.userId = [dictionary[@"user_id"] integerValue];
    user.username = dictionary[@"username"];
    
    return user;
}

@end
