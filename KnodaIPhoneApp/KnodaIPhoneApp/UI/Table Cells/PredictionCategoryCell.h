//
//  PredictionCategoryCell.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseTableViewCell.h"

@interface PredictionCategoryCell : BaseTableViewCell

@property (nonatomic) NSString *category;
@property (nonatomic) BOOL buttonEnabled;

@end
