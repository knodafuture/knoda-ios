//
//  BigDaddyPredictionCell.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/15/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PredictionCell;
@class Prediction;
@protocol PredictionCellDelegate;

@interface BigDaddyPredictionCell : UITableViewCell

@property (strong, nonatomic) PredictionCell *predictionCell;
@property (weak, nonatomic) IBOutlet UIView *agreeDisagreeView;
@property (weak, nonatomic) IBOutlet UIView *predictionStatusView;
@property (weak, nonatomic) IBOutlet UIView *settlePredictionView;
@property (weak, nonatomic) IBOutlet UILabel *outcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *outcomeImageView;
@property (weak, nonatomic) IBOutlet UILabel *totalPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsBreakdownLabel;

@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *disagreeButton;

@property (weak, nonatomic) IBOutlet UIView *settleOtherUsersPrediction;


+ (BigDaddyPredictionCell *)predictionCellWithOwner:(id<PredictionCellDelegate>)owner;

- (void)configureWithPrediction:(Prediction *)prediction;
- (void)update;

- (CGFloat)heightForPrediction:(Prediction *)prediction;

@end
