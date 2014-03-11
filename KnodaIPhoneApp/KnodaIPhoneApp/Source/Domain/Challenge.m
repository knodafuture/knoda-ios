//
//  NewChallenge.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Challenge.h"

@implementation Challenge

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"challengeId": @"id",
             @"isOwn": @"is_own",
             @"isRight": @"is_right",
             @"isFinished": @"is_finished",
             @"isBS": @"bs"
             };
}

@end
