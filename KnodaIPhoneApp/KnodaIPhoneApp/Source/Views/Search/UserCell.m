//
//  UserCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "UserCell.h"

static UINib *nib;

@implementation UserCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"UserCell" bundle:[NSBundle mainBundle]];
}

+ (UserCell *)userCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    cell.indexPath = indexPath;
    return cell;
}

- (IBAction)follow:(id)sender {
    [self.delegate didFollowInCell:self onIndexPath:self.indexPath];
}

- (void)setFollowing:(BOOL)following {
    _following = following;
    
    if (following)
        [self.followingButton setImage:[UIImage imageNamed:@"FollowBtnActive"] forState:UIControlStateNormal];
    else
        [self.followingButton setImage:[UIImage imageNamed:@"FollowBtn"] forState:UIControlStateNormal];
}

@end
