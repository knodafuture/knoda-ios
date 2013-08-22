//
//  AnotherUserPredictionsWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AnotherUserPredictionsWebRequest.h"
#import "Prediction.h"

@interface AnotherUserPredictionsWebRequest() {
    NSInteger _userId;
}

@property (nonatomic, strong) NSArray* predictions;

@end

@implementation AnotherUserPredictionsWebRequest

- (id)initWithUserId:(NSInteger)userId {
    if(self = [super init]) {
        _userId = userId;
    }
    return self;
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
        [predictionArray addObject: prediction];
    }
    
    self.predictions = [NSArray arrayWithArray: predictionArray];
}

@end
