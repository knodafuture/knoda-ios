//
//  SideNavCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideNavCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

+ (SideNavCell *)sideNavCellForTableView:(UITableView *)tableView;

@end
