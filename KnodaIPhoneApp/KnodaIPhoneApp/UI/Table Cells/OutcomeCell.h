//
//  FinishedPredictionCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@class Prediction;

@interface OutcomeCell : BaseTableViewCell

@property (nonatomic, assign) BOOL loading;

- (void)setupCellWithPrediction:(Prediction *)prediction;

+ (CGFloat)cellHeightForPrediction:(Prediction *)prediction;

@end
