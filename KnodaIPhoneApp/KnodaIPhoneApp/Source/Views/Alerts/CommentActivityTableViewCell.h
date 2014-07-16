//
//  CommentActivityTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 7/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityItem;

@interface CommentActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;

+ (CommentActivityTableViewCell *)cellForTableView:(UITableView *)tableView;
+ (CGFloat)heightForActivityItem:(ActivityItem *)activityItem;

- (void)populate:(ActivityItem *)activityItem;

@end
