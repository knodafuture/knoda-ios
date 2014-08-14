//
//  LoadingCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 13.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoadingCell.h"

const CGFloat loadingCellHeight = 38.0;

static UINib *nib;

@interface LoadingCell()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoadingCell

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.activityIndicator startAnimating];
}

+ (void)initialize {
    nib = [UINib nibWithNibName:@"LoadingCell" bundle:[NSBundle mainBundle]];
}

+ (LoadingCell *)loadingCellForTableView:(UITableView *)tableView {
    LoadingCell *cell = (LoadingCell *)[tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

@end
