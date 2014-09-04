//
//  FollowersTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "FollowersTableViewCell.h"

static UINib *nib;

@implementation FollowersTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"FollowersTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (FollowersTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<FollowersTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath {
    
    FollowersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowerCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;
        cell.avatarImageView.clipsToBounds = YES;
    }
    cell.delegate = delegate;
    cell.indexPath = indexPath;
    
    return cell;
}

- (void)populate:(User *)user {
    self.usernameLabel.text = user.name;
    self.following = user.followingId != nil;
    if (!user.verifiedAccount) {
        self.verifiedCheckmark.hidden = YES;
    } else {
        self.verifiedCheckmark.hidden = NO;
        CGSize textSize = [self.usernameLabel sizeThatFits:self.usernameLabel.frame.size];
        
        CGRect frame = self.verifiedCheckmark.frame;
        frame.origin.x = self.usernameLabel.frame.origin.x + textSize.width + 5.0;
        self.verifiedCheckmark.frame = frame;
    }
    

}

- (void)setFollowing:(BOOL)following {
    _following = following;
    
    if (following)
        [self.followingButton setImage:[UIImage imageNamed:@"FollowBtnActive"] forState:UIControlStateNormal];
    else
        [self.followingButton setImage:[UIImage imageNamed:@"FollowBtn"] forState:UIControlStateNormal];
}

- (IBAction)followButton:(id)sender {
    [self.delegate followButtonTappedInCell:self atIndexPath:self.indexPath];
}

@end
