//
//  Rivalry.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "Rivalry.h"

@implementation Rivalry
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userWon": @"user_won",
             @"opponentWon" : @"opponent_won"
             };
}
@end
