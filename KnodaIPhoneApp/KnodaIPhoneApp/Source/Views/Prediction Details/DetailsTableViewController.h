//
//  DetailsTableViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"
#import "PredictionCell.h"

@class Prediction;
@class Comment;
@class PredictionDetailsHeaderCell;
@class User;
@interface DetailsTableViewController : BaseTableViewController

@property (strong, nonatomic) Prediction *prediction;
@property (strong, nonatomic) PredictionDetailsHeaderCell *headerCell;


- (id)initWithPrediction:(Prediction *)prediction andOwner:(id<PredictionCellDelegate>)owner;

- (void)showComments;
- (void)showTally;

- (void)addComment:(Comment *)newComment;
- (void)updateTallyForUser:(User *)user agree:(BOOL)agree;

@end
