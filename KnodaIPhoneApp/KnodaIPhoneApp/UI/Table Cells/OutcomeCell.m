//
//  FinishedPredictionCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "OutcomeCell.h"

#import "Prediction.h"
#import "Chellange.h"

static const float kBigCellHeight   = 151.0;
static const float kSmallCellHeight = 99.0;

@interface OutcomeCell()

@property (nonatomic, strong) IBOutlet UILabel* promptLabel;
@property (nonatomic, weak) IBOutlet UIButton *unfinishedButton;

@end

@implementation OutcomeCell

- (void)setupCellWithPrediction:(Prediction *)prediction {
    self.promptLabel.text = (prediction.chellange.isOwn) ? (NSLocalizedString(@"Was your prediction correct?", @"")) : NSLocalizedString(@"Was this prediction correct?", @"");
    self.unfinishedButton.hidden = ![prediction isExpired] || !prediction.chellange.isOwn;
}

+ (CGFloat)cellHeightForPrediction:(Prediction *)prediction {
    return [prediction isExpired] ? kBigCellHeight : kSmallCellHeight;
}

@end
