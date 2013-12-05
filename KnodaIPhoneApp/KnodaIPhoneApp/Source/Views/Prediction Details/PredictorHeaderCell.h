//
//  PredictorHeaderCell.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/23/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat PredictorHeaderCellHeight;

@interface PredictorHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

+ (PredictorHeaderCell *)predictorHeaderCellForTableView:(UITableView *)tableView;


@end
