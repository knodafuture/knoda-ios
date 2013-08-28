//
//  PredictionUpdateWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 15.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionUpdateWebRequest.h"

#import "Prediction.h"

#import "NSDate+Utils.h"

@interface PredictionUpdateWebRequest() {
    NSInteger _predictionId;
    BOOL _patch;
}

@end

@implementation PredictionUpdateWebRequest

- (id)initWithPredictionId:(NSInteger)predictionId {
    if(self = [super init]) {
        _predictionId = predictionId;
    }
    return self;
}

- (id)initWithPredictionId:(NSInteger)predictionId patch:(NSDictionary *)params {
    if(self = [super initWithParameters:params]) {
        DLog(@"%@", parameters);
        _patch = YES;
        _predictionId = predictionId;
    }
    return self;
}

- (id)initWithPredictionId:(NSInteger)predictionId extendTill:(NSDate *)expDate {
    NSDateComponents *dc = [expDate gmtDateComponents];
    NSDictionary *params = @{@"prediction[expires_at(1i)]" : @(dc.year),
                             @"prediction[expires_at(2i)]" : @(dc.month),
                             @"prediction[expires_at(3i)]" : @(dc.day),
                             @"prediction[expires_at(4i)]" : @(dc.hour),
                             @"prediction[expires_at(5i)]" : @(dc.minute)};
    return ((self = [self initWithPredictionId:predictionId patch:params]));
}

- (NSString *)httpMethod {
    return _patch ? @"PATCH" : @"GET";
}

- (NSString *)methodName {
    return [NSString stringWithFormat:@"predictions/%d.json", _predictionId];
}

- (BOOL)requiresAuthToken {
    return YES;
}

- (BOOL)isMultipartData {
    return _patch;
}

- (void)fillResultObject:(id)parsedResult {
    DLog(@"%@", parsedResult);
    
    _prediction = [[Prediction alloc] initWithDictionary:parsedResult];
    if ([parsedResult[@"my_challenge"] isKindOfClass:[NSDictionary class]]) {
        [_prediction setupChallenge:parsedResult[@"my_challenge"] withPoints:parsedResult[@"my_points"]];
    }
}

@end
