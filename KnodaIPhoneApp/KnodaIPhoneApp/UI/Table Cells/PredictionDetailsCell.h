//
//  PredictionDetailsCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 13.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PreditionCell.h"

@class Prediction;

@interface PredictionDetailsCell : PreditionCell

+ (CGFloat)cellHeightForPrediction:(Prediction *)prediction;

@end
