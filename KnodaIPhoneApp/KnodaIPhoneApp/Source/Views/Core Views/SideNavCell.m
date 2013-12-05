//
//  SideNavCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SideNavCell.h"

static UINib *nib;

@implementation SideNavCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"SideNavCell" bundle:[NSBundle mainBundle]];
}

+ (SideNavCell *)sideNavCellForTableView:(UITableView *)tableView {
    SideNavCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideNavCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

@end
