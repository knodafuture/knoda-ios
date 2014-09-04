//
//  SocialFollowTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/25/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SocialFollowTableViewCell.h"

static UINib *nib;

@interface SocialFollowTableViewCell ()
@end

@implementation SocialFollowTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"SocialFollowTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (SocialFollowTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<SocialFollowTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath {
    SocialFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialFollowCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;
        cell.avatarImageView.clipsToBounds = YES;
    }
    cell.checked = NO;
    cell.delegate = delegate;
    cell.indexPath = indexPath;
    
    return cell;
}


- (void)setChecked:(BOOL)checked {
    if (!checked) {
        [self.checkbox setImage:[UIImage imageNamed:@"InviteCheckbox"] forState:UIControlStateNormal];
        _checked = NO;
    } else {
        [self.checkbox setImage:[UIImage imageNamed:@"InviteCheckboxActive"] forState:UIControlStateNormal];
        _checked = YES;
    }
}
- (IBAction)toggleChecked:(id)sender {
    if (self.checked) {
        self.checked = NO;
        [self.delegate matchUnselectedInSocialFollowTableViewCell:self atIndexPath:self.indexPath];
    } else {
        self.checked = YES;
        [self.delegate matchSelectedInSocialFollowTableViewCell:self atIndexPath:self.indexPath];
    }
}

@end
