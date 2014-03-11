//
//  PredictorCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

UIKIT_EXTERN CGFloat PredictorCellHeight;

@class User;
@protocol PredictorCellDelegate <NSObject>

- (void)predictorCellDidSelectUserWithUserId:(NSInteger)userId;

@end



@interface PredictorCell : UITableViewCell

@property (weak, nonatomic) id<PredictorCellDelegate> delegate;

+ (PredictorCell *)predictorCellForTableView:(UITableView *)tableView;

- (void)setAgreedUser:(User *)agreedUser andDisagreedUser:(User *)disagreedUser;


@end

