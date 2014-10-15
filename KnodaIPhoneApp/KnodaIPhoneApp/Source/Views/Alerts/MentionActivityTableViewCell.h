//
//  MentionActivityTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 10/12/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityItem;
@interface MentionActivityTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;

+ (MentionActivityTableViewCell *)cellForTableView:(UITableView *)tableView;
+ (CGFloat)heightForActivityItem:(ActivityItem *)activityItem;

- (void)populate:(ActivityItem *)activityItem;

@end
