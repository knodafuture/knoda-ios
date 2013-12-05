//
//  PredictorCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

UIKIT_EXTERN CGFloat PredictorCellHeight;

@interface PredictorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *agreedUserName;
@property (weak, nonatomic) IBOutlet UILabel *disagreedUserName;

+ (PredictorCell *)predictorCellForTableView:(UITableView *)tableView;

@end

