//
//  UserProfileHeaderView.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BindableView;
@class User;
@interface UserProfileHeaderView : UIView

@property (weak, nonatomic) IBOutlet BindableView *userAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *streakLabel;
@property (weak, nonatomic) IBOutlet UILabel *winPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *winLossLabel;

@property (weak, nonatomic) IBOutlet UILabel *smallPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallWLLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallStreakLabel;


- (void)populateWithUser:(User *)user;

@end