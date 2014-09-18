//
//  HeadToHeadBarView.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "HeadToHeadBarView.h"
#import "User.h"

@implementation HeadToHeadBarView

- (id)init {
    self = [[[UINib nibWithNibName:@"HeadToHeadBarView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    self.leftImageView.layer.cornerRadius = self.leftImageView.frame.size.height / 2.0;
    self.leftImageView.clipsToBounds = YES;
    self.leftImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.leftImageView.layer.borderWidth = 1.0;
    self.rightImageView.layer.cornerRadius = self.leftImageView.frame.size.height / 2.0;
    self.rightImageView.clipsToBounds = YES;
    self.rightImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.rightImageView.layer.borderWidth = 1.0;
    return self;
}


- (void)populateWithLeftUser:(User *)leftUser rightUser:(User *)rightUser animated:(BOOL)animated {
    
    NSInteger leftWins = rightUser.rivalry.opponentWon;
    NSInteger rightWins = rightUser.rivalry.userWon;
    NSInteger totalWins = leftWins + rightWins;
    
    CGFloat maxWidth = 106;
    CGFloat leftWidth = 0, rightWidth = 0;
    
    if (totalWins != 0) {
        leftWidth = (float)leftWins/(float)totalWins * maxWidth;
        rightWidth = (float)rightWins/(float)totalWins * maxWidth;
    }
    
    CGRect frame = self.leftView.frame;
    frame.size.width = leftWidth;
    frame.origin.x = self.leftImageView.frame.origin.x + 5.0 - frame.size.width;
    self.leftView.frame = frame;
    
    frame = self.rightView.frame;
    frame.size.width = rightWidth;
    self.rightView.frame = frame;
    
    self.leftLabel.text = [NSString stringWithFormat:@"%ld", (long)leftWins];
    self.rightLabel.text = [NSString stringWithFormat:@"%ld", (long)rightWins];
    self.visitingUserLabel.text = rightUser.name;
}
@end
