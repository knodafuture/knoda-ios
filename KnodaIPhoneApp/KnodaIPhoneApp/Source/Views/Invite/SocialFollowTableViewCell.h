//
//  SocialFollowTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/25/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SocialFollowTableViewCell;

@protocol SocialFollowTableViewCellDelegate <NSObject>

- (void)matchSelectedInSocialFollowTableViewCell:(SocialFollowTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)matchUnselectedInSocialFollowTableViewCell:(SocialFollowTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@interface SocialFollowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkbox;
@property (weak, nonatomic) id<SocialFollowTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) BOOL checked;
+ (SocialFollowTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<SocialFollowTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath;


@end
