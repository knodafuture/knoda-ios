//
//  HistoryMyPicksWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/14/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HistoryMyPicksWebRequest.h"
#import "Prediction.h"
#import "Chellange.h"


static const NSInteger kPageResultsLimit = 25;


@implementation HistoryMyPicksWebRequest

+ (NSInteger) limitByPage
{
    return kPageResultsLimit;
}


- (id) init
{
    NSDictionary* params = @{@"list": @"picks"};
    
    self = [super initWithParameters: params];
    return self;
}


- (id) initWithLastCreatedDate: (NSDate*) lastCreatedDate
{
    NSDictionary* params = @{@"list": @"picks", @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"created_at_lt" : lastCreatedDate};
    
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
    NSLog(@"My picks result: %@", parsedResult);
    
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
