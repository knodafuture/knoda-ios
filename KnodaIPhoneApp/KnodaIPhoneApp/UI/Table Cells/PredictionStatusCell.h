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

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UIView  *bsView;

@property (nonatomic) BOOL isRight;

- (IBAction)bsButtonTapped:(UIButton *)sender;

- (void)setupCellWithPrediction:(Prediction *)prediction;

+ (CGFloat)heightForPrediction:(Prediction *)prediction;

@end
