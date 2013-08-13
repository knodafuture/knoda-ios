//
//  FinishedPredictionCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "OutcomeCell.h"

#import "Prediction.h"

static const float kBigCellHeight   = 151.0;
static const float kSmallCellHeight = 99.0;

@interface OutcomeCell()

@property (nonatomic, weak) IBOutlet UIButton *unfinishedButton;

@end

@implementation OutcomeCell

- (void)setupCellWithPrediction:(Prediction *)prediction {
    self.unfinishedButton.hidden = !prediction.expired;
}

+ (CGFloat)cellHeightForPrediction:(Prediction *)prediction {
    return prediction.expired ? kBigCellHeight : kSmallCellHeight;
}

@end
