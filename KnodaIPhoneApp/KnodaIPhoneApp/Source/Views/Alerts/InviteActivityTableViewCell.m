//
//  InviteActivityTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "InviteActivityTableViewCell.h"
#import "ActivityItem.h"

static UINib *nib;

@implementation InviteActivityTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"InviteActivityTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (InviteActivityTableViewCell *)cellForTableView:(UITableView *)tableView {
    InviteActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteActivity"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

- (void)populate:(ActivityItem *)item {
    self.titleLabel.text = item.title;
    
    [self.inviteButton setTitle:item.body forState:UIControlStateNormal];

    self.titleLabel.textColor = [UIColor colorFromHex:@"235C37"];
    
    if (item.seen) {
        self.dotImageView.hidden = YES;
    } else {
        CGRect frame = self.dotImageView.frame;
        frame.origin.x = self.avatarImageView.frame.origin.x + self.avatarImageView.frame.size.width - frame.size.width;
        frame.origin.y = self.avatarImageView.frame.origin.y + self.avatarImageView.frame.size.height - frame.size.height;
        self.dotImageView.frame = frame;
    }
}

@end
