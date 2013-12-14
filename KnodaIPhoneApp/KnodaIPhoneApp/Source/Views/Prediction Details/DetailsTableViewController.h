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
@interface DetailsTableViewController : BaseTableViewController

@property (strong, nonatomic) Prediction *prediction;

- (id)initWithPrediction:(Prediction *)prediction andOwner:(id<PredictionCellDelegate>)owner;

- (void)showComments;
- (void)showTally;

- (void)addComment:(Comment *)newComment;
- (void)updateTallyForUser:(NSString *)username agree:(BOOL)agree;

@end
