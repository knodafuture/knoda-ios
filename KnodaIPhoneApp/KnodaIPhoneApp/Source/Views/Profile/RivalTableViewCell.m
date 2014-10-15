//
//  RivalTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "RivalTableViewCell.h"
#import "HeadToHeadBarView.h"
#import "User.h"

static UINib *nib;

@implementation RivalTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"RivalTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (RivalTableViewCell *)cellForTableView:(UITableView *)tableView {
    RivalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RivalCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.barView = [[HeadToHeadBarView alloc] init];
        
        CGRect frame = cell.barView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        cell.barView.frame = frame;
        
        [cell.innerView addSubview:cell.barView];
        
    }
    return cell;
}

- (void)populateWithLeftUser:(User *)leftUser rightUser:(User *)rightUser {
    [self.barView populateWithLeftUser:leftUser rightUser:rightUser animated:NO];
    
    if ([leftUser.winningPercentage isEqual:@0])
        self.leftWinPercentLabel.text = @"0%";
    else if ([leftUser.winningPercentage isEqual:@100])
        self.leftWinPercentLabel.text = @"100%";
    else
        self.leftWinPercentLabel.text = [NSString stringWithFormat:@"%3.2f%@",leftUser.winningPercentage.floatValue,@"%"];
    self.leftStreakLabel.text = [leftUser.streak length] > 0 ? leftUser.streak : @"W0";
    self.leftWinLossLabel.text = [NSString stringWithFormat:@"%lu-%lu",(unsigned long)leftUser.won,(unsigned long)leftUser.lost];
    
    if ([rightUser.winningPercentage isEqual:@0])
        self.rightWinPercentLabel.text = @"0%";
    else if ([rightUser.winningPercentage isEqual:@100])
        self.rightWinPercentLabel.text = @"100%";
    else
        self.rightWinPercentLabel.text = [NSString stringWithFormat:@"%3.2f%@",rightUser.winningPercentage.floatValue,@"%"];
    self.rightStreakLabel.text = [rightUser.streak length] > 0 ? rightUser.streak : @"W0";
    self.rightWinLossLabel.text = [NSString stringWithFormat:@"%lu-%lu",(unsigned long)rightUser.won,(unsigned long)rightUser.lost];
    
    
    UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    
    if (leftUser.won > rightUser.won) {
        self.leftWinLossLabel.font = boldFont;
        self.rightWinLossLabel.font = regularFont;
    } else if (leftUser.won < rightUser.won) {
        self.leftWinLossLabel.font = regularFont;
        self.rightWinLossLabel.font = boldFont;
    } else {
        self.leftWinLossLabel.font = regularFont;
        self.rightWinLossLabel.font = regularFont;
    }
    
    if (leftUser.winningPercentage.floatValue > rightUser.winningPercentage.floatValue) {
        self.leftWinPercentLabel.font = boldFont;
        self.rightWinPercentLabel.font = regularFont;
    } else if (leftUser.winningPercentage.floatValue < rightUser.winningPercentage.floatValue) {
        self.leftWinPercentLabel.font = regularFont;
        self.rightWinPercentLabel.font = boldFont;
    } else {
        self.rightWinPercentLabel.font = regularFont;
        self.leftWinPercentLabel.font = regularFont;
    }
    
    if ([self streakIsWinning:leftUser.streak] && ![self streakIsWinning:rightUser.streak]) {
        self.leftStreakLabel.font = boldFont;
        self.rightStreakLabel.font = regularFont;
    } else if (![self streakIsWinning:leftUser.streak] && [self streakIsWinning:rightUser.streak]) {
        self.leftStreakLabel.font = regularFont;
        self.rightStreakLabel.font = boldFont;
    } else if ([self streakIsWinning:leftUser.streak] && [self streakIsWinning:rightUser.streak]) {
        if ([self streakLength:leftUser.streak] > [self streakLength:rightUser.streak]) {
            self.leftStreakLabel.font = boldFont;
            self.rightStreakLabel.font = regularFont;
        } else if ([self streakLength:leftUser.streak] > [self streakLength:rightUser.streak]) {
            self.leftStreakLabel.font = regularFont;
            self.rightStreakLabel.font = boldFont;
        } else {
            self.leftStreakLabel.font = regularFont;
            self.rightStreakLabel.font = regularFont;
        }
    } else if (![self streakIsWinning:leftUser.streak] && ![self streakIsWinning:rightUser.streak]) {
        if ([self streakLength:leftUser.streak] < [self streakLength:rightUser.streak]) {
            self.leftStreakLabel.font = boldFont;
            self.rightStreakLabel.font = regularFont;
        }
        else if ([self streakLength:leftUser.streak] < [self streakLength:rightUser.streak]) {
            self.leftStreakLabel.font = regularFont;
            self.rightStreakLabel.font = boldFont;
        } else {
            self.leftStreakLabel.font = regularFont;
            self.rightStreakLabel.font = regularFont;
        }
    } else {
        self.leftStreakLabel.font = regularFont;
        self.rightStreakLabel.font = regularFont;
    }
    
}

- (BOOL)streakIsWinning:(NSString *)streak {
    if ([streak rangeOfString:@"W"].location != NSNotFound || streak.length == 0)
        return YES;
    return NO;
}

- (NSInteger)streakLength:(NSString *)streak {
    return [streak substringFromIndex:1].integerValue;
}

@end
