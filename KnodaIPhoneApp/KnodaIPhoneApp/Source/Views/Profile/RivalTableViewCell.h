//
//  RivalTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 9/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class HeadToHeadBarView;

@interface RivalTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftWinLossLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftWinPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftStreakLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightWinLossLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightWinPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightStreakLabel;

@property (strong, nonatomic) HeadToHeadBarView *barView;

+ (RivalTableViewCell *)cellForTableView:(UITableView *)tableView;

- (void)populateWithLeftUser:(User *)leftUser rightUser:(User *)rightUser;

@end
