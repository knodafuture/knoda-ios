//
//  Topic.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Topic.h"

@implementation Topic

+ (NSString *)responseKey {
    return @"topics";
}

+ (id)instanceFromDictionary:(NSDictionary *)dictionary {
    Topic *topic = [super instanceFromDictionary:dictionary];
    
    topic.name = dictionary[@"name"];
    
    return topic;
}

@end
