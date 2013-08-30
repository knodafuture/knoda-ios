//
//  AnotherUserPredictionsWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AnotherUserPredictionsWebRequest.h"
#import "Prediction.h"

static const NSInteger kPageResultsLimit = 25;

@interface AnotherUserPredictionsWebRequest() {
    NSInteger _userId;
}

@property (nonatomic, strong) NSArray* predictions;

@end

@implementation AnotherUserPredictionsWebRequest

- (id)initWithUserId:(NSInteger)userId {
    NSDictionary* params = @{@"offset": [NSNumber numberWithInteger: 0], @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"count" : [NSNumber numberWithInteger: 1]};
    
    self = [super initWithParameters: params];
    _userId = userId;

    return self;
}

- (id) initWithLastId: (NSInteger) lastId andUserID : (NSInteger) userId
{
    NSDictionary* params = @{@"offset": [NSNumber numberWithInteger: 0], @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"count" : [NSNumber numberWithInteger: 1], @"id_lt" : @(lastId)};
    
    self = [super initWithParameters: params];
    _userId = userId;
    return self;
}

- (BOOL) requiresAuthToken
{
    return YES;
}

+ (NSInteger) limitByPage
{
    return kPageResultsLimit;
}

- (NSString*) methodName
{
    NSString *format = @"users/%d/predictions.json";
    return [NSString stringWithFormat:format, _userId];
}

- (void) fillResultObject: (id) parsedResult
{
    NSMutableArray* predictionArray = [[NSMutableArray alloc] initWithCapacity: 0];
    
    NSArray* resultArray = [parsedResult objectForKey: @"predictions"];
    
    for (NSDictionary* predictionDictionary in resultArray)
    {
        Prediction* prediction = [[Prediction alloc] initWithDictionary:predictionDictionary];
        if ([predictionDictionary[@"my_challenge"] isKindOfClass:[NSDictionary class]]) {
            [prediction setupChallenge:predictionDictionary[@"my_challenge"] withPoints:predictionDictionary[@"my_points"]];
        }
        [predictionArray addObject: prediction];
    }
    
    self.predictions = [NSArray arrayWithArray: predictionArray];
}

@end
