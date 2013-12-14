//
//  PreditionCell.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PredictionCell;
@class Prediction;
@protocol PredictionCellDelegate <NSObject>

- (void)predictionAgreed:(Prediction *)prediction inCell:(PredictionCell *)cell;
- (void)predictionDisagreed:(Prediction *)prediction inCell:(PredictionCell *)cell;
- (void)profileSelectedWithUserId:(NSInteger) userId inCell:(PredictionCell *)cell;

@end


@interface PredictionCell : UITableViewCell

@property (weak, nonatomic) id<PredictionCellDelegate> delegate;
@property (nonatomic, assign) BOOL agreed;
@property (nonatomic, assign) BOOL disagreed;
@property (weak, nonatomic) Prediction *prediction;
@property (assign, nonatomic) BOOL swipeEnabled;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (void)fillWithPrediction:(Prediction *) prediction;
- (void)updateDates;
- (void)update;


+ (PredictionCell *)predictionCellForTableView:(UITableView *)tableView;
+ (CGFloat)heightForPrediction:(Prediction *)prediction;

- (IBAction)profileTapped:(id)sender;
@end
