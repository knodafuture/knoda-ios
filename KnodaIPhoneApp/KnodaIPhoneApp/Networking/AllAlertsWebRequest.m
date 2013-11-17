//
//  AllAlertsWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AllAlertsWebRequest.h"
#import "Prediction.h"
#import "Challenge.h"


@implementation AllAlertsWebRequest

- (id) init
{
    NSDictionary* params = @{@"list": @"notifications_unviewed"};
    
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
