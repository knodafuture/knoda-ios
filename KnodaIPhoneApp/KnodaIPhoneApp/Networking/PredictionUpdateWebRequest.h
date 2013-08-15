//
//  PredictionUpdateWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 15.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@class Prediction;

@interface PredictionUpdateWebRequest : BaseWebRequest

@property (nonatomic, readonly) Prediction *prediction;

- (id)initWithPredictionId:(NSInteger)predictionId;
- (id)initWithPredictionId:(NSInteger)predictionId patch:(NSDictionary *)params;
- (id)initWithPredictionId:(NSInteger)predictionId extendTill:(NSDate *)expDate;

@end
