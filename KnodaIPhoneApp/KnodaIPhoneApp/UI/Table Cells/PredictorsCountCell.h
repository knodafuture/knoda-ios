//
//  PredictorsCountCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface PredictorsCountCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *agreedLabel;
@property (weak, nonatomic) IBOutlet UILabel *disagreedLabel;

@property (nonatomic) NSUInteger agreedCount;
@property (nonatomic) NSUInteger disagreedCount;


@end
