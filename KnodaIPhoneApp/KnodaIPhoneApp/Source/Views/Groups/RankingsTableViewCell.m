//
//  RankingsTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/24/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "RankingsTableViewCell.h"

static UINib *nib;

@implementation RankingsTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"RankingsTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (RankingsTableViewCell *)cellForTableView:(UITableView *)tableView {
    RankingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rankingsCell"];
    
    if (!cell)  {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;
        cell.avatarImageView.clipsToBounds = YES;
        
    }
    
    return cell;
}


@end
