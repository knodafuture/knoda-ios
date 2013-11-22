//
//  UserProfileHeaderView.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UserProfileHeaderView.h"
#import "User.h"
#import "BindableView.h"

static UINib *nib;

@implementation UserProfileHeaderView

+ (void)initialize {
    nib = [UINib nibWithNibName:@"UserProfileHeaderView" bundle:[NSBundle mainBundle]];
}

- (id)init {
    self = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return self;
}


- (void)populateWithUser:(User *)user {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    
    self.pointsLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithInteger:user.points]]];
    self.winPercentLabel.text = [NSString stringWithFormat:@"%3.2f%%", [user.winningPercentage floatValue]];
    self.streakLabel.text = [user.streak length] > 0 ? user.streak : @"-";
    self.winLossLabel.text = [NSString stringWithFormat:@"%d-%d",user.won,user.lost];
    
    
    CGSize textSize = [self.pointsLabel sizeThatFits:self.pointsLabel.frame.size];
    
    CGRect frame = self.smallPointsLabel.frame;
    frame.origin.x = self.pointsLabel.frame.origin.x + textSize.width + 2.0;
    self.smallPointsLabel.frame = frame;
    
    textSize = [self.winPercentLabel sizeThatFits:self.winPercentLabel.frame.size];
    
    frame = self.streakLabel.frame;
    frame.origin.x = self.winPercentLabel.frame.origin.x + textSize.width + 10.0;
    self.streakLabel.frame = frame;
    
    frame = self.smallStreakLabel.frame;
    frame.origin.x = self.streakLabel.frame.origin.x + 1.0;
    self.smallStreakLabel.frame = frame;
    
    textSize = [self.streakLabel sizeThatFits:self.streakLabel.frame.size];
    
    frame = self.winLossLabel.frame;
    frame.origin.x = self.streakLabel.frame.origin.x + textSize.width + 10.0;
    self.winLossLabel.frame = frame;
    
    frame = self.smallWLLabel.frame;
    frame.origin.x = self.winLossLabel.frame.origin.x + 1.0;
    self.smallWLLabel.frame = frame;
    
    [self.userAvatarView bindToURL:user.bigImage];
}
@end
