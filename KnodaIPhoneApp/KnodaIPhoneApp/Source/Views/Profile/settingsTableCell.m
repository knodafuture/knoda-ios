//
//  settingsTableCell.m
//  KnodaIPhoneApp
//
//  Created by Grant Isom on 6/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "settingsTableCell.h"

static UINib *nib;

@implementation settingsTableCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"settingsTableCell" bundle:[NSBundle mainBundle]];
}

+ (settingsTableCell *)cellForTableView:(UITableView *)tableView {
    settingsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] firstObject];
    return cell;
}


@end
