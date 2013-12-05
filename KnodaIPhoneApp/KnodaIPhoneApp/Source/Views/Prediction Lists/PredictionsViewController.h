//
//  PredictionsViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"
#import "PredictionDetailsViewController.h"
#import "PredictionCell.h"

@class Prediction;
@interface PredictionsViewController : BaseTableViewController <PredictionDetailsDelegate, PredictionCellDelegate>

@end
