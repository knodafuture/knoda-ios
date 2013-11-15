//
//  PreditionCell.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "BindableView.h"

@class Prediction;
@class PredictionCell;


@protocol PredictionCellDelegate <NSObject>

@optional
- (void) predictionAgreed: (Prediction*) prediction inCell: (PredictionCell*) cell;
- (void) predictionDisagreed: (Prediction*) prediction inCell: (PredictionCell*) cell;
- (void) profileSelectedWithUserId: (NSInteger) userId inCell: (PredictionCell*) cell;

@end


@interface PredictionCell : BaseTableViewCell <UIGestureRecognizerDelegate, BindableViewProtocol>

@property (nonatomic, strong) IBOutlet UILabel* bodyLabel;
@property (nonatomic, strong) IBOutlet UILabel* metadataLabel;

@property (nonatomic, strong) IBOutlet UIImageView* guessMarkImage;

@property (nonatomic, assign) BOOL agreed;
@property (nonatomic, assign) BOOL disagreed;

@property (nonatomic, weak) id<PredictionCellDelegate> delegate;

@property (nonatomic, strong) Prediction* prediction;

- (void) addPanGestureRecognizer: (UIPanGestureRecognizer*) recognizer;
- (void) setUpUserProfileTapGestures : (UITapGestureRecognizer*) recognizer;
- (void) fillWithPrediction: (Prediction*) prediction;
- (void) resetAgreedDisagreed;

- (void) updateDates;

- (void) update;
- (void) updateGuessMark;

@end
