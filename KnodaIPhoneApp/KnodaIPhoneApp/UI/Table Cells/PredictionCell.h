//
//  PreditionCell.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BindableView.h"

@class Prediction;
@class PredictionCell;

const extern CGFloat defaultCellHeight;

@protocol PredictionCellDelegate <NSObject>

@optional
- (void) predictionAgreed: (Prediction*) prediction inCell: (PredictionCell*) cell;
- (void) predictionDisagreed: (Prediction*) prediction inCell: (PredictionCell*) cell;
- (void) profileSelectedWithUserId: (NSInteger) userId inCell: (PredictionCell*) cell;

@end


@interface PredictionCell : UITableViewCell <BindableViewProtocol>

@property (nonatomic, weak) id<PredictionCellDelegate> delegate;

@property (nonatomic, strong) Prediction* prediction;

- (void) setUpUserProfileTapGestures : (UITapGestureRecognizer*) recognizer;
- (void) fillWithPrediction: (Prediction*) prediction;
- (void) resetAgreedDisagreed;
- (void) updateDates;
- (void) update;

+ (PredictionCell *)predictionCellForTableView:(UITableView *)tableView;
+ (CGFloat)heightForPrediction:(Prediction *)prediction;


@end