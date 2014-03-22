//
//  GroupTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "GroupTableViewCell.h"

static UINib *nib;


@implementation GroupTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"GroupTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (GroupTableViewCell *)cellForTableView:(UITableView *)tableView {
    GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] firstObject];
    return cell;
}

@end
