//
//  PredictionStatusCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@class Prediction;

@interface PredictionStatusCell : BaseTableViewCell

@property (nonatomic) BOOL isRight;

- (IBAction)bsButtonTapped:(UIButton *)sender;

- (void)setupCellWithPrediction:(Prediction *)prediction;

+ (CGFloat)cellHeightForPrediction:(Prediction *)prediction;

@end
