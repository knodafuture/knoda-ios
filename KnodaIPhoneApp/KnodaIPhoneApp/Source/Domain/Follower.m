//
//  Follower.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Follower.h"

@implementation Follower
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"leaderId": @"leader_id"
             };
}
@end
