//
//  WinActivityTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WinActivityTableViewCell;

@protocol WinActivityTableViewCellDelegate <NSObject>

@optional
- (void)WinActivityTableViewCell:(WinActivityTableViewCell *)cell didBragOnIndexPath:(NSIndexPath *)indexPath;

@end

@interface WinActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<WinActivityTableViewCellDelegate> delegate;

+ (WinActivityTableViewCell *)cellForTableView:(UITableView *)tableView onIndexPath:(NSIndexPath *)indexPath delegate:(id<WinActivityTableViewCellDelegate>)delegate;

@end
