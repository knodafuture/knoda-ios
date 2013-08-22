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


- (id) initWithOffset: (NSInteger) offset andTag:(NSString *)tag
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"recent" : @"true",
                                     @"limit"  : @(kPageResultsLimit),
                                     @"offset" : @(offset)}];
    if(tag.length) {
        [params setObject:tag forKey:@"tag"];
    }
    self = [super initWithParameters: params];
    return self;
}


- (id) initWithLastID: (NSInteger) lastID andTag:(NSString *)tag
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"recent": @"true",
                                     @"limit" : @(kPageResultsLimit),
                                     @"id_lt" : @(lastID)}];
    if(tag.length) {
        [params setObject:tag forKey:@"tag"];
    }
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
