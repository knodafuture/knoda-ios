//
//  MemberTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "MemberTableViewCell.h"


static UINib *nib;

@implementation MemberTableViewCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"MemberTableViewCell" bundle:[NSBundle mainBundle]];
}

+ (MemberTableViewCell *)cellForTableView:(UITableView *)tableView {
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] firstObject];
    
    return cell;
}

@end
