//
//  ChellangeByPredictionWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ChellangeByPredictionWebRequest.h"


@interface ChellangeByPredictionWebRequest ()

@property (nonatomic, assign) NSInteger predictionID;

@end


@implementation ChellangeByPredictionWebRequest

- (id) initWithPredictionID: (NSInteger) predictionID
{
    self = [super init];
    
    if (self != nil)
    {
        self.predictionID = predictionID;
    }
    
    return self;
}


- (NSString*) methodName
{
    return [NSString stringWithFormat: @"predictions/%d/challenge.json", self.predictionID];
}


- (BOOL) requiresAuthToken
{
    return YES;
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Chellange result: %@", parsedResult);
    
    Chellange* chellange = [[Chellange alloc] init];
    chellange.seen = [[parsedResult objectForKey: @"seen"] boolValue];
    chellange.agree = [[parsedResult objectForKey: @"agree"] boolValue];
    chellange.isOwn = [[parsedResult objectForKey: @"is_own"] boolValue];
    chellange.isRight = [[parsedResult objectForKey: @"is_right"] boolValue];
    chellange.isFinished = [[parsedResult objectForKey: @"is_finished"] boolValue];
    
    NSDictionary* pointsDictionary = [parsedResult objectForKey: @"points_details"];
    
    chellange.basePoints = [[pointsDictionary objectForKey: @"base_points"] integerValue];
    chellange.marketSizePoints = [[pointsDictionary objectForKey: @"market_size_points"] integerValue];
    chellange.outcomePoints = [[pointsDictionary objectForKey: @"outcome_points"] integerValue];
    chellange.predictionMarketPoints = [[pointsDictionary objectForKey: @"prediction_market_points"] integerValue];
    
    self.chellange = chellange;
}


@end
