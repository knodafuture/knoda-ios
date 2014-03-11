//
//  PredictionPoints.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/10/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "PredictionPoints.h"

@implementation PredictionPoints
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"basePoints": @"base_points",
             @"outcomePoints": @"outcome_points",
             @"market_size_points" : @"market_size_points",
             @"predictionMarketPoints": @"prediction_market_points"
             };
}
@end
