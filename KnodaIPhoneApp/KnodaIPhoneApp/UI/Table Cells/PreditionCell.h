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

@interface PreditionCell : BaseTableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL agreed;
@property (nonatomic, assign) BOOL disagreed;

- (void) addPanGestureRecognizer: (UIPanGestureRecognizer*) recognizer;
- (void) fillWithPrediction: (Prediction*) prediction;

- (void) updateDates;

@end
