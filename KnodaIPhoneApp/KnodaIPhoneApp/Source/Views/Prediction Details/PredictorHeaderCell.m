//
//  PredictorHeaderCell.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/23/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictorHeaderCell.h"

static UINib *nib;

CGFloat PredictorHeaderCellHeight = 44.0;

@implementation PredictorHeaderCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"PredictorHeaderCell" bundle:[NSBundle mainBundle]];
}

+ (PredictorHeaderCell *)predictorHeaderCellForTableView:(UITableView *)tableView {
    PredictorHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PredictorHeaderCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
    
}


@end
