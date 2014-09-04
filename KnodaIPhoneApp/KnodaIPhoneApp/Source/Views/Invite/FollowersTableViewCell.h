//
//  FollowersTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@class FollowersTableViewCell;

@protocol FollowersTableViewCellDelegate <NSObject>

- (void)followButtonTappedInCell:(FollowersTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface FollowersTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedCheckmark;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) id<FollowersTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) BOOL following;

+ (FollowersTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<FollowersTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath;


- (void)populate:(User *)user;
@end
