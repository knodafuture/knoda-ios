//
//  Badge.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Badge.h"

@implementation Badge

+ (NSString *)responseKey {
    return @"badges";
}

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    Badge *badge = [super instanceFromDictionary:dictionary];
    
    badge.name = dictionary[@"name"];
    
    return badge;
}

@end
