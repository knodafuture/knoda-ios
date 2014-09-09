//
//  FollowingActivityTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityItem+Utils.h"

@class FollowingActivityTableViewCell;
@protocol FollowingActivityTableViewCellDelegate <NSObject>

- (void)didFollowInCell:(FollowingActivityTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface FollowingActivityTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) id<FollowingActivityTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;
@property (assign, nonatomic) BOOL following;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
+ (FollowingActivityTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<FollowingActivityTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath;

- (void)populate:(ActivityItem *)activityItem;
@end
