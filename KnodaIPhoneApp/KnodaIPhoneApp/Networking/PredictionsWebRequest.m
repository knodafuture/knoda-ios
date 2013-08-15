//
//  LoginWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionsWebRequest.h"
#import "Prediction.h"
#import "Chellange.h"


static const NSInteger kPageResultsLimit = 7;


@interface PredictionsWebRequest ()

@property (nonatomic, strong) NSArray* predictions;

@end


@implementation PredictionsWebRequest


+ (NSInteger) limitByPage
{
    return kPageResultsLimit;
}


- (id) initWithOffset: (NSInteger) offset
{
    NSDictionary* params = @{@"recent": @"true", @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"offset" : [NSNumber numberWithInteger: offset]};
    
    self = [super initWithParameters: params];
    return self;
}


- (id) initWithLastID: (NSInteger) lastID
{
    NSDictionary* params = @{@"recent": @"true", @"limit" : [NSNumber numberWithInteger: kPageResultsLimit], @"id_lt" : [NSNumber numberWithInteger: lastID]};
    
    self = [super initWithParameters: params];
    return self;
}


- (NSString*) methodName
{
    return @"predictions.json";
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Predictions Result: %@", parsedResult);
    
    NSMutableArray* predictionArray = [[NSMutableArray alloc] initWithCapacity: 0];
    
    NSArray* resultArray = [parsedResult objectForKey: @"predictions"];
    
    for (NSDictionary* predictionDictionary in resultArray)
    {
        Prediction* prediction = [[Prediction alloc] initWithDictionary:predictionDictionary];
        [predictionArray addObject: prediction];
    }
    
    self.predictions = [NSArray arrayWithArray: predictionArray];
}


- (BOOL) requiresAuthToken
{
    return YES;
}


@end
