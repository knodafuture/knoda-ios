//
//  BigDaddyPredictionCell.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/15/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BigDaddyPredictionCell.h"
#import "PredictionCell.h"  
#import "Prediction.h"  
#import "Challenge.h"

static const int kObserverKeyCount = 12;
static NSString* const PREDICTION_OBSERVER_KEYS[kObserverKeyCount] = {
    @"doNotObserve",
    @"expirationDate",
    @"agreedPercent",
    @"expired",
    @"outcome",
    @"settled",
    @"smallAvatar",
    @"chellange",
    @"chellange.seen",
    @"chellange.agree",
    @"chellange.isRight",
    @"chellange.isFinished"
};

static UINib *nib;

@interface BigDaddyPredictionCell ()
@property (strong, nonatomic) Prediction *prediction;

@end

@implementation BigDaddyPredictionCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"BigDaddyPredictionCell" bundle:[NSBundle mainBundle]];
    
}

+ (BigDaddyPredictionCell *)predictionCellWithOwner:(id<PredictionCellDelegate>)owner {
    
    BigDaddyPredictionCell *cell = [[nib instantiateWithOwner:owner options:nil] lastObject];
    
    cell.predictionCell = [PredictionCell predictionCellForTableView:nil];
    cell.predictionCell.delegate = owner;
    
    [cell addSubview:cell.predictionCell];
    
    CGRect frame = cell.predictionCell.frame;
    frame.origin.y = 0;
    cell.predictionCell.frame = frame;
    
    return cell;
}

- (void)configureWithPrediction:(Prediction *)prediction {
    
    self.prediction = prediction;
    
    [self.predictionCell fillWithPrediction:prediction];
    
    
    
    CGRect frame = self.frame;
    if ([self showsActionArea])
        frame.size.height = self.predictionCell.frame.size.height + self.agreeDisagreeView.frame.size.height;
    else
        frame.size.height = self.predictionCell.frame.size.height;
    self.frame = frame;
    
    frame = self.agreeDisagreeView.frame;
    frame.origin.y = self.predictionCell.frame.size.height;
    
    self.agreeDisagreeView.frame = frame;
    self.settlePredictionView.frame = frame;
    self.predictionStatusView.frame = frame;
    
    [self update];
    
}

- (void)update {
    [self.predictionCell update];
    [self configureVariableSpot];
    
}

- (BOOL)showsActionArea {
    if (self.prediction.hasOutcome && self.prediction.chellange)
        return YES;
    else if (self.prediction.canSetOutcome)
        return YES;
    else if (![self.prediction isExpired] && !self.prediction.chellange.isOwn)
        return YES;
    else {
        return NO;
    }
}

- (void)configureVariableSpot {
    
    if (self.prediction.hasOutcome && self.prediction.chellange)
        [self updateAndShowPredictionStatusView];
    else if (self.prediction.canSetOutcome && self.prediction.chellange.isOwn)
        [self updateAndShowSettlePredictionView];
    else if (self.prediction.canSetOutcome && !self.prediction.chellange.isOwn)
        [self updateAndShowSettleOther];
    else if (![self.prediction isExpired] && !self.prediction.chellange.isOwn)
        [self updateAndShowAgreeDisagreeView];
    else {
        self.settlePredictionView.hidden = YES;
        self.predictionStatusView.hidden = YES;
        self.agreeDisagreeView.hidden = YES;
    }
}

- (void)updateAndShowSettleOther {
    self.settlePredictionView.hidden = YES;
    self.predictionStatusView.hidden = YES;
    self.agreeDisagreeView.hidden = YES;
    self.settleOtherUsersPrediction.hidden = NO;
}

- (void)updateAndShowAgreeDisagreeView {
    self.settlePredictionView.hidden = YES;
    self.predictionStatusView.hidden = YES;
    self.agreeDisagreeView.hidden = NO;
    self.settleOtherUsersPrediction.hidden = YES;
    
    if (self.prediction.iAgree) {
        self.agreeButton.backgroundColor = [UIColor colorFromHex:@"235C37"];
        self.disagreeButton.backgroundColor = [UIColor colorFromHex:@"77BC1F"];
    } else if (self.prediction.iDisagree) {
        self.agreeButton.backgroundColor = [UIColor colorFromHex:@"77BC1F"];
        self.disagreeButton.backgroundColor = [UIColor colorFromHex:@"234C37"];
    } else {
        self.agreeButton.backgroundColor = [UIColor colorFromHex:@"77BC1F"];
        self.disagreeButton.backgroundColor = [UIColor colorFromHex:@"77BC1F"];
    }
}
- (void)updateAndShowPredictionStatusView {
    self.settlePredictionView.hidden = YES;
    self.predictionStatusView.hidden = NO;
    self.agreeDisagreeView.hidden = YES;
    self.settleOtherUsersPrediction.hidden = YES;
    
    self.pointsBreakdownLabel.text = [self.prediction pointsString];
    
    self.totalPointsLabel.text = [NSString stringWithFormat:@"%d", [self.prediction totalPoints]];
    
    if ([self.prediction win]) {
        self.outcomeLabel.text = @"YOU WON!";
        self.outcomeImageView.image = [UIImage imageNamed:@"ResultsWinIcon"];
    } else {
        self.outcomeLabel.text = @"YOU LOST!";
        self.outcomeImageView.image = [UIImage imageNamed:@"ResultsLoseIcon"];
    }
    
}
- (void)updateAndShowSettlePredictionView {
    self.settlePredictionView.hidden = NO;
    self.predictionStatusView.hidden = YES;
    self.agreeDisagreeView.hidden = YES;
    self.settleOtherUsersPrediction.hidden = YES;
}

#pragma mark KVO
- (void)setPrediction:(Prediction *)prediction {
    if(_prediction != prediction) {
        if(_prediction) {
            [self removeKVO];
        }
        _prediction = prediction;
        if(_prediction) {
            [self addKVO];
        }
    }
}

- (void)dealloc {
    [self removeKVO];
}
- (void)addKVO {
    for(int i = 0; i < kObserverKeyCount; i++) {
        [self.prediction addObserver:self forKeyPath:PREDICTION_OBSERVER_KEYS[i] options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeKVO {
    for(int i = 0; i < kObserverKeyCount; i++) {
        [self.prediction removeObserver:self forKeyPath:PREDICTION_OBSERVER_KEYS[i]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([object isKindOfClass:[Prediction class]]) {
        if(![(Prediction *)object doNotObserve]) {
            [self update];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    
}

@end
