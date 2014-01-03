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

+ (UserCell *)userCellForTableView:(UITableView *)tableView {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

@end
