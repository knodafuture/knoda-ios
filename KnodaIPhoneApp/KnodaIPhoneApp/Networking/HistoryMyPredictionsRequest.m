//
//  HistoryMyPredictionsRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/14/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HistoryMyPredictionsRequest.h"
#import "Challenge.h"
#import "Prediction.h"

static const NSInteger kPageResultsLimit = 25;

@implementation HistoryMyPredictionsRequest


+ (NSInteger) limitByPage
{
    return kPageResultsLimit;
}


- (id) init
{
    NSDictionary* params = @{@"list": @"ownedAndPicked", @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"offset" : [NSNumber numberWithInteger: 0]};
    
    self = [super initWithParameters: params];
    return self;
}


- (id) initWithLastCreatedDate: (NSDate*) lastCreatedDate
{
    NSDictionary* params = @{@"list": @"ownedAndPicked", @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"created_at_lt" : lastCreatedDate};
    
    self = [super initWithParameters: params];
    return self;
}

- (id)initWithOffset:(NSInteger)offset {
    NSDictionary* params = @{@"list": @"ownedAndPicked", @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"offset" : [NSNumber numberWithInteger: offset]};
    
    self = [super initWithParameters: params];
    return self;
}

- (NSString*) methodName
{
    return @"challenges.json";
}


- (BOOL) requiresAuthToken
{
    return YES;
}


- (void) fillResultObject: (id) parsedResult
{
    
    NSMutableArray* predictionsMutable = [NSMutableArray arrayWithCapacity: 0];
    
    NSArray* challengeArray = [parsedResult objectForKey: @"challenges"];
    
    for (NSDictionary* challengeDictionary in challengeArray)
    {
        Prediction* prediction = [[Prediction alloc] initWithDictionary:challengeDictionary[@"prediction"]];
        [prediction setupChallenge:challengeDictionary withPoints:challengeDictionary[@"points_details"]];
        [predictionsMutable addObject: prediction];
    }
    
    self.predictions = [NSArray arrayWithArray: predictionsMutable];
}


@end
