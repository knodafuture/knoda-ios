//
//  SettleActivityTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 7/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityItem;

@interface SettleActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *settleButton;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
+ (CGFloat)heightForActivityItem:(ActivityItem *)item;
+ (SettleActivityTableViewCell *)cellForTableView:(UITableView *)tableView;

- (void)populate:(ActivityItem *)item;


@end
