//
//  AutocompleteMentionTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 10/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "AutocompleteMentionTableViewCell.h"

static UINib *nib;

@implementation AutocompleteMentionTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"AutocompleteMentionTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (AutocompleteMentionTableViewCell *)cellForTableView:(UITableView *)tableView {
    AutocompleteMentionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MentionCell"];
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;
        cell.avatarImageView.clipsToBounds = YES;
        
    }
    return cell;
}

@end
