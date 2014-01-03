
//
//  NoSearchResultsCell.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NoSearchResultsCell.h"


CGFloat NoSearchResultsCellHeight = 36.0;

static UINib *nib;

@implementation NoSearchResultsCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"NoSearchResultsCell" bundle:[NSBundle mainBundle]];
}

+ (NoSearchResultsCell *)noSearchResultsCellWithTitle:(NSString *)title forTableView:(UITableView *)tableView {
    
    NoSearchResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noSearchResultsCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    cell.titleLabel.text = title;
    
    return cell;
}

@end
