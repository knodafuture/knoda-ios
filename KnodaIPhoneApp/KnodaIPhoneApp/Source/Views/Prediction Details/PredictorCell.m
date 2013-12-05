//
//  PredictorCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictorCell.h"

static UINib *nib;

CGFloat PredictorCellHeight = 22.0;

@implementation PredictorCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"PredictorCell" bundle:[NSBundle mainBundle]];
}

+ (PredictorCell *)predictorCellForTableView:(UITableView *)tableView {
    PredictorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PredictorCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

@end
