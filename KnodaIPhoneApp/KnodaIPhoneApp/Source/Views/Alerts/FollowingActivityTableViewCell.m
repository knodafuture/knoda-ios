//
//  FollowingActivityTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "FollowingActivityTableViewCell.h"

static UINib *nib;

@implementation FollowingActivityTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"FollowingActivityTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (FollowingActivityTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<FollowingActivityTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath {
    FollowingActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowingCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;
        cell.avatarImageView.clipsToBounds = YES;
    }
    
    cell.delegate = delegate;
    cell.indexPath = indexPath;
    
    return cell;
}

- (void)populate:(ActivityItem *)activityItem {
    
    self.usernameLabel.text = activityItem.body;
    if (activityItem.seen) {
        self.dotImageView.hidden = YES;
    } else {
        CGRect frame = self.dotImageView.frame;
        frame.origin.x = self.avatarImageView.frame.origin.x + self.avatarImageView.frame.size.width - frame.size.width;
        frame.origin.y = self.avatarImageView.frame.origin.y + self.avatarImageView.frame.size.height - frame.size.height;
    }
}

- (void)setFollowing:(BOOL)following {
    _following = following;
    
    if (following)
        [self.followingButton setImage:[UIImage imageNamed:@"FollowBtnActive"] forState:UIControlStateNormal];
    else
        [self.followingButton setImage:[UIImage imageNamed:@"FollowBtn"] forState:UIControlStateNormal];
}

- (IBAction)follow:(id)sender {
    [self.delegate didFollowInCell:self atIndexPath:self.indexPath];
}

@end
