//
//  AlertCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat AlertCellHeight;

@interface AlertCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;

+ (AlertCell *)alertCellForTableView:(UITableView *)tableView;

@end
