//
//  PredictionItemProvider.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Prediction;
@interface PredictionItemProvider : UIActivityItemProvider <UIActivityItemSource>

- (id)initWithPrediction:(Prediction *)prediction;

@end
