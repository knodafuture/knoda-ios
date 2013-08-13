//
//  PredictorCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface PredictorCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *agreedUserName;
@property (weak, nonatomic) IBOutlet UILabel *disagreedUserName;

@end
