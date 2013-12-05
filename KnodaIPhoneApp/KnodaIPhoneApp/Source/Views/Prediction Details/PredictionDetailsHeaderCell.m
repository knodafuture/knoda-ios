//
//  BigDaddyPredictionCell.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/15/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsHeaderCell.h"
#import "PredictionCell.h"  
#import "Prediction+Utils.h"
#import "Challenge.h"
#import "WebApi.h"

static UINib *nib;

@interface PredictionDetailsHeaderCell ()
@property (strong, nonatomic) Prediction *prediction;

@end

@implementation PredictionDetailsHeaderCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"PredictionDetailsHeaderCell" bundle:[NSBundle mainBundle]];
    
}

+ (PredictionDetailsHeaderCell *)predictionCellWithOwner:(id<PredictionCellDelegate>)owner {
    
    PredictionDetailsHeaderCell *cell = [[nib instantiateWithOwner:owner options:nil] lastObject];
    
    cell.predictionCell = [PredictionCell predictionCellForTableView:nil];
    cell.predictionCell.delegate = owner;
    cell.predictionCell.swipeEnabled = NO;
    [cell addSubview:cell.predictionCell];
    
    CGRect frame = cell.predictionCell.frame;
    frame.origin.y = 0;
    cell.predictionCell.frame = frame;
    
    return cell;
}

- (CGFloat)heightForPrediction:(Prediction *)prediction {
    CGFloat baseHeight = [PredictionCell heightForPrediction:prediction];
    
    if ([self showsActionArea])
        return baseHeight + self.agreeDisagreeView.frame.size.height;
    else
        return baseHeight;
    
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
    self.settleOtherUsersPrediction.frame = frame;
    
    [self update];
    
}

- (void)update {
    [self.predictionCell update];
    [self configureVariableSpot];
    
    if (!self.predictionCell.avatarImageView.image)
        [[WebApi sharedInstance] getImage:self.prediction.smallAvatarUrl completion:^(UIImage *image, NSError *error) {
            if (image && !error)
                self.predictionCell.avatarImageView.image = image;
        }];
}

- (BOOL)showsActionArea {
    if (self.prediction.hasOutcome && self.prediction.challenge)
        return YES;
    else if (self.prediction.canSetOutcome)
        return YES;
    else if (![self.prediction isExpired] && !self.prediction.challenge.isOwn)
        return YES;
    else {
        return NO;
    }
}

- (void)configureVariableSpot {
    
    if (self.prediction.hasOutcome && self.prediction.challenge)
        [self updateAndShowPredictionStatusView];
    else if (self.prediction.canSetOutcome && self.prediction.challenge.isOwn)
        [self updateAndShowSettlePredictionView];
    else if (self.prediction.canSetOutcome && !self.prediction.challenge.isOwn)
        [self updateAndShowSettleOther];
    else if (![self.prediction isExpired] && !self.prediction.challenge.isOwn)
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

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    
}

@end
