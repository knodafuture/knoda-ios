
//
//  NewUser.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSString *)responseKey {
    return @"users";
}

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    
    User *user = [super instanceFromDictionary:dictionary];
    
    user.userId = [dictionary[@"id"] integerValue];
    user.name = dictionary[@"username"];
    user.email = dictionary[@"email"];
    user.points = [dictionary[@"points"] integerValue];
    user.won = [dictionary[@"won"] integerValue];
    user.lost = [dictionary[@"lost"] integerValue];
    user.winningPercentage = [NSNumber numberWithFloat:[dictionary[@"winning_percentage"] floatValue]];
    user.streak = dictionary[@"streak"];
    user.alerts = [dictionary[@"alerts"] integerValue];
    user.badges = [dictionary[@"badges"] integerValue];
    
    
    NSDictionary *avatarImages = dictionary[@"avatar_image"];
    
    if(![avatarImages isKindOfClass:[NSNull class]] && avatarImages.count) {
        user.thumbImageUrl = avatarImages[@"thumb"];
        user.smallImageUrl = avatarImages[@"small"];
        user.largeImageUrl   = avatarImages[@"big"];
    }
    
    return user;
    
}


@end
