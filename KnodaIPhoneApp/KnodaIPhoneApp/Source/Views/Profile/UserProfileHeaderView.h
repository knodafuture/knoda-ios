//
//  UserProfileHeaderView.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class UserProfileHeaderView;
@protocol UserProfileHeaderViewDelegate <NSObject>

- (void)twitterButtonPressedInHeaderView:(UserProfileHeaderView *)headerView;
- (void)facebookButtonPressedInHeaderView:(UserProfileHeaderView *)headerView;

@end

@interface UserProfileHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *streakLabel;
@property (weak, nonatomic) IBOutlet UILabel *winPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *winLossLabel;

@property (weak, nonatomic) IBOutlet UIImageView *twitterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *facebookImageView;

- (id)initWithDelegate:(id<UserProfileHeaderViewDelegate>)delegate;

- (void)populateWithUser:(User *)user;

@end
