//
//  Chellange.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/30/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Chellange.h"


@implementation Chellange

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [super init]) {
        self.ID         = [[dictionary objectForKey: @"id"] integerValue];
        self.seen       = [[dictionary objectForKey: @"seen"] boolValue];
        self.agree      = [[dictionary objectForKey: @"agree"] boolValue];
        self.isOwn      = [[dictionary objectForKey: @"is_own"] boolValue];
        self.isRight    = [[dictionary objectForKey: @"is_right"] boolValue];
        self.isFinished = [[dictionary objectForKey: @"is_finished"] boolValue];
        self.isBS       = [[dictionary objectForKey: @"bs"] boolValue];
        
        NSDictionary* pointsDictionary = [dictionary objectForKey: @"my_points"];
        
        self.basePoints             = [[pointsDictionary objectForKey: @"base_points"] integerValue];
        self.marketSizePoints       = [[pointsDictionary objectForKey: @"market_size_points"] integerValue];
        self.outcomePoints          = [[pointsDictionary objectForKey: @"outcome_points"] integerValue];
        self.predictionMarketPoints = [[pointsDictionary objectForKey: @"prediction_market_points"] integerValue];
    }
    return self;
}

@end
