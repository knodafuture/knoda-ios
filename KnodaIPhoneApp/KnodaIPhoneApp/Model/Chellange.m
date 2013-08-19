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
    }
    return self;
}

- (void)fillPoints:(NSDictionary *)dictionary {
    self.basePoints             = [[dictionary objectForKey: @"base_points"] integerValue];
    self.marketSizePoints       = [[dictionary objectForKey: @"market_size_points"] integerValue];
    self.outcomePoints          = [[dictionary objectForKey: @"outcome_points"] integerValue];
    self.predictionMarketPoints = [[dictionary objectForKey: @"prediction_market_points"] integerValue];
}


- (NSString*) description
{
    NSString* result = [NSString stringWithFormat: @"\r~~CHELLANGE~~\rid: %d\rseen: %@\ragree: %@\risOwn: %@\risRight: %@\risFinished: %@\risBS: %@\rbasePoints: %d\routcomePoints: %d\rmarketSizePoints: %d\rpredictionMarketPoints: %d\r~~", self.ID, (self.seen) ? @"YES" : @"NO", (self.agree) ? @"YES" : @"NO", (self.isOwn) ? @"YES" : @"NO", (self.isRight) ? @"YES" : @"NO", (self.isFinished) ? @"YES" : @"NO", (self.isBS) ? @"YES" : @"NO", self.basePoints, self.outcomePoints, self.marketSizePoints, self.predictionMarketPoints];
    
    return result;
}


@end
