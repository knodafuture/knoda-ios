//
//  WinActivityTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WinActivityTableViewCell.h"

static UINib *nib;

@implementation WinActivityTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"WinActivityTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (WinActivityTableViewCell *)cellForTableView:(UITableView *)tableView onIndexPath:(NSIndexPath *)indexPath delegate:(id<WinActivityTableViewCellDelegate>)delegate {
 
    WinActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WinActivity"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    
    cell.indexPath = indexPath;
    cell.delegate = delegate;
    cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;
    cell.avatarImageView.clipsToBounds = YES;
    return cell;
}

@end
