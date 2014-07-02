//
//  WinActivityTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResultActivityTableViewCell;
@class ActivityItem;
@protocol ResultActivityTableViewCellDelegate <NSObject>

@optional
- (void)resultActivityTableViewCell:(ResultActivityTableViewCell *)cell didBragForActivityItem:(ActivityItem *)activityItem;

@end

@interface ResultActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *bragButton;

@property (strong, nonatomic) ActivityItem *activityItem;
@property (weak, nonatomic) id<ResultActivityTableViewCellDelegate> delegate;

+ (ResultActivityTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<ResultActivityTableViewCellDelegate>)delegate;

+ (CGFloat)heightForActivityItem:(ActivityItem *)activityItem;

- (void)populate:(ActivityItem *)activityItem;

- (IBAction)brag:(id)sender;

@end
