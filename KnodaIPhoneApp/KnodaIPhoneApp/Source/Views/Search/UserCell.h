//
//  UserCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@class UserCell;

@protocol UserCellDelegate <NSObject>

- (void)didFollowInCell:(UserCell *)cell onIndexPath:(NSIndexPath *)indexPath;

@end

@interface UserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) id<UserCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) BOOL following;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
+ (UserCell *)userCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;



@end
