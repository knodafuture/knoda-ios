//
//  PreditionCell.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseTableViewCell.h"

@class Prediction;
@class PreditionCell;


@protocol PredictionCellDelegate <NSObject>

- (void) predictionAgreed: (Prediction*) prediction inCell: (PreditionCell*) cell;
- (void) predictionDisagreed: (Prediction*) prediction inCell: (PreditionCell*) cell;

@end


@interface PreditionCell : BaseTableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UILabel* bodyLabel;
@property (nonatomic, strong) IBOutlet UILabel* metadataLabel;

@property (nonatomic, assign) BOOL agreed;
@property (nonatomic, assign) BOOL disagreed;

@property (nonatomic, weak) id<PredictionCellDelegate> delegate;

- (void) addPanGestureRecognizer: (UIPanGestureRecognizer*) recognizer;
- (void) fillWithPrediction: (Prediction*) prediction;
- (void) resetAgreedDisagreed;

- (void) updateDates;

@end
