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

#import "PredictionDetailsCell.h"
#import "PredictionCategoryCell.h"
#import "PredictionStatusCell.h"
#import "MakePredictionCell.h"
#import "OutcomeCell.h"
#import "LoadingCell.h"

#import "PredictorsCountCell.h"
#import "PredictorCell.h"

#import "AddPredictionViewController.h"

typedef enum {
    RowEmpty = 0,
    RowPrediction,
    RowCategory,
    RowStatus,
    RowPredictorsCount,
    RowMakePrediction,
    RowOutcome,
    RowPredictor,
    RowLoading,
    TableRowsBaseCount = RowPredictorsCount,
} CellType;

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";

@interface PredictionDetailsViewController () <AddPredictionViewControllerDelegate> {
    BOOL _loadingUsers;
}

@property (nonatomic) NSArray *agreedUsers;
@property (nonatomic) NSArray *disagreedUsers;

@end

@implementation PredictionDetailsViewController

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.prediction.agreeCount || self.prediction.disagreeCount) {
        _loadingUsers = YES;
    }
}

#pragma mark Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kAddPredictionSegue]) {
        ((AddPredictionViewController*)segue.destinationViewController).delegate = self;
    }
}

#pragma mark Private

- (CellType)cellTypeForIndexpath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: return RowPrediction;
        case 1: return RowCategory;
        case 2:
            if(self.prediction.outcome) {
                return RowStatus;
            }
            else if(self.prediction.chellange.isOwn) {
                return RowOutcome;
            }
            else if(!self.prediction.chellange) {
                return RowMakePrediction;
            }
            return RowEmpty;
        case 3:  return RowPredictorsCount;
        default: return _loadingUsers ? RowLoading : RowPredictor;
    }
}

- (Class)cellClassForIndexpath:(NSIndexPath *)indexPath {
    switch ([self cellTypeForIndexpath:indexPath]) {
        case RowPrediction:         return [PredictionDetailsCell class];
        case RowCategory:           return [PredictionCategoryCell class];
        case RowStatus:             return [PredictionStatusCell class];
        case RowMakePrediction:     return [MakePredictionCell class];
        case RowOutcome:            return [OutcomeCell class];
        case RowPredictorsCount:    return [PredictorsCountCell class];
        case RowPredictor:          return [PredictorCell class];
        case RowEmpty:              return [BaseTableViewCell class];
        case RowLoading:            return [LoadingCell class];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TableRowsBaseCount + (_loadingUsers ? 1 : MAX(self.agreedUsers.count, self.disagreedUsers.count));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class cellClass = [self cellClassForIndexpath:indexPath];    
    BaseTableViewCell *baseCell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[cellClass reuseIdentifier]];
    
    if([baseCell isKindOfClass:[PredictionDetailsCell class]]) {
        PredictionDetailsCell *cell = (PredictionDetailsCell *)baseCell;
        [cell fillWithPrediction:self.prediction];
    }
    else if([baseCell isKindOfClass:[PredictionCategoryCell class]]) {
        PredictionCategoryCell *cell = (PredictionCategoryCell *)baseCell;
        [cell setCategory:self.prediction.category];
    }
    else if([baseCell isKindOfClass:[PredictionStatusCell class]]) {
        PredictionStatusCell *cell = (PredictionStatusCell *)baseCell;
        [cell setupCellWithPrediction:self.prediction];
    }
    else if([baseCell isKindOfClass:[MakePredictionCell class]]) {
        
    }
    else if([baseCell isKindOfClass:[PredictorsCountCell class]]) {
        PredictorsCountCell *cell = (PredictorsCountCell *)baseCell;
        cell.agreedCount    = self.prediction.agreeCount;
        cell.disagreedCount = self.prediction.disagreeCount;
    }
    else if([baseCell isKindOfClass:[PredictorCell class]]) {
        PredictorCell *cell = (PredictorCell *)baseCell;
        int idx = indexPath.row - TableRowsBaseCount;
        cell.agreedUserName.text    = self.agreedUsers.count > idx ? self.agreedUsers[idx] : @"";
        cell.disagreedUserName.text = self.disagreedUsers.count > idx ? self.disagreedUsers[idx] : @"";
    }
    else if([baseCell isKindOfClass:[OutcomeCell class]]) {
        OutcomeCell *cell = (OutcomeCell *)baseCell;
        [cell setupCellWithPrediction:self.prediction];
    }
    
    return baseCell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self cellTypeForIndexpath:indexPath]) {
        case RowStatus:
            return [PredictionStatusCell cellHeightForPrediction:self.prediction];
        case RowPrediction:
            return [PredictionDetailsCell cellHeightForPrediction:self.prediction];
        case RowOutcome:
            return [OutcomeCell cellHeightForPrediction:self.prediction];
        case RowEmpty:
            return 0.0;
        case RowLoading:
            return 44.0;
        default:
            return [[self cellClassForIndexpath:indexPath] cellHeight];
    }
}

#pragma mark AddPredictionViewControllerDelegate

- (void) predictinMade {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
