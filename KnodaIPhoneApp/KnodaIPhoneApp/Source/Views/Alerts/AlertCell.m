//
//  AlertCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AlertCell.h"

CGFloat AlertCellHeight = 61.0;

static UINib *nib;

@implementation AlertCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"AlertCell" bundle:[NSBundle mainBundle]];
}

+ (AlertCell *)alertCellForTableView:(UITableView *)tableView {
    AlertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertCell"];

    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}


@end
