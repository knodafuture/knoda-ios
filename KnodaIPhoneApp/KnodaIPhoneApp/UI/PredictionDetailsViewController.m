//
//  PredictionDetailsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsViewController.h"

#import "Prediction.h"
#import "Chellange.h"

#import "PreditionCell.h"
#import "PredictionCategoryCell.h"
#import "PredictionStatusCell.h"
#import "MakePredictionCell.h"
#import "OutcomeCell.h"

#import "PredictorsCountCell.h"
#import "PredictorCell.h"

typedef enum {
    RowPrediction = 1,
    RowCategory,
    RowStatus,
    RowPredictorsCount,
    RowMakePrediction,
    RowOutcome,
    RowPredictor,
    TableRowsBaseCount = RowPredictorsCount,
} CellType;

@interface PredictionDetailsViewController ()

@property (nonatomic) NSArray *agreedUsers;
@property (nonatomic) NSArray *disagreedUsers;

@end

@implementation PredictionDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.agreedUsers = @[@"User1", @"User2", @"User3"];
    self.disagreedUsers = @[@"User1", @"User2"];
}

- (CellType)cellTypeForIndexpath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: return RowPrediction;
        case 1: return RowCategory;
        case 2: return RowOutcome; //self.prediction.chellange.isFinished ? RowStatus : RowMakePrediction;
        case 3: return RowPredictorsCount;
        default: return RowPredictor;
    }
}

- (Class)cellClassForIndexpath:(NSIndexPath *)indexPath {
    switch ([self cellTypeForIndexpath:indexPath]) {
        case RowPrediction:         return [PreditionCell class];
        case RowCategory:           return [PredictionCategoryCell class];
        case RowStatus:             return [PredictionStatusCell class];
        case RowMakePrediction:     return [MakePredictionCell class];
        case RowOutcome: return [OutcomeCell class];
        case RowPredictorsCount:    return [PredictorsCountCell class];
        case RowPredictor:          return [PredictorCell class];
    }
}

#pragma mark Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TableRowsBaseCount + MAX(self.agreedUsers.count, self.disagreedUsers.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class cellClass = [self cellClassForIndexpath:indexPath];
    BaseTableViewCell *baseCell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[cellClass reuseIdentifier]];
    
    if([baseCell isKindOfClass:[PreditionCell class]]) {
        PreditionCell *cell = (PreditionCell *)baseCell;
        [cell fillWithPrediction:self.prediction];
    }
    else if([baseCell isKindOfClass:[PredictionCategoryCell class]]) {
        //PredictionDetailsCategoryCell *cell = (PredictionDetailsCategoryCell *)baseCell;
    }
    else if([baseCell isKindOfClass:[PredictionStatusCell class]]) {
        PredictionStatusCell *cell = (PredictionStatusCell *)baseCell;
        [cell setupCellWithPrediction:self.prediction];
    }
    else if([baseCell isKindOfClass:[MakePredictionCell class]]) {
        //MakePredictionCell *cell = (MakePredictionCell *)baseCell;
        
    }
    else if([baseCell isKindOfClass:[PredictorsCountCell class]]) {
        PredictorsCountCell *cell = (PredictorsCountCell *)baseCell;
        cell.agreedCount    = self.agreedUsers.count;
        cell.disagreedCount = self.disagreedUsers.count;
    }
    else if([baseCell isKindOfClass:[PredictorCell class]]) {
        PredictorCell *cell = (PredictorCell *)baseCell;
        int idx = indexPath.row - TableRowsBaseCount;
        cell.agreedUserName.text    = self.agreedUsers.count > idx ? self.agreedUsers[idx] : @"";
        cell.disagreedUserName.text = self.disagreedUsers.count > idx ? self.disagreedUsers[idx] : @"";
    }
    
    return baseCell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self cellTypeForIndexpath:indexPath]) {
        case RowStatus:
            return [PredictionStatusCell heightForPrediction:self.prediction];
        default:
            return [[self cellClassForIndexpath:indexPath] cellHeight];
    }
}

@end
