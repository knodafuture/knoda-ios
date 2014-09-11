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

UIKIT_EXTERN NSString *PredictionVotedEvent;
UIKIT_EXTERN NSString *PredictionVotedKey;

@class Prediction;
@interface PredictionsViewController : BaseTableViewController <PredictionDetailsDelegate, PredictionCellDelegate>


- (void)updatePrediction:(Prediction *)prediction;
@end
