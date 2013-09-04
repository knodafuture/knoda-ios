//
//  MyPredictionsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "MyPredictionsViewController.h"
#import "PreditionCell.h"
#import "HistoryMyPredictionsRequest.h"
#import "Prediction.h"
#import "PredictionDetailsViewController.h"
#import "AddPredictionViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "ProfileViewController.h"
#import "ChildControllerDataSource.h"
#import "PredictionUpdateWebRequest.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";
static NSString* const kMyProfileSegue = @"MyProfileSegue";

@interface MyPredictionsViewController () <AddPredictionViewControllerDelegate, PredictionCellDelegate, PredictionDetailsDelegate> {
    BOOL _isRefreshing;
    BOOL _needLoadNextPage;
}

@property (nonatomic, strong) NSTimer* cellUpdateTimer;

@end


@implementation MyPredictionsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    self.cellUpdateTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self selector: @selector(updateVisibleCells) userInfo: nil repeats: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cellUpdateTimer invalidate];
    self.cellUpdateTimer = nil;
}

- (void) updateVisibleCells
{
    NSArray* visibleCells = [self.tableView visibleCells];
    
    for (UITableViewCell* cell in visibleCells)
    {
        if([cell isKindOfClass:[PreditionCell class]]) {
            [(PreditionCell *)cell updateDates];
        }
    }
}

- (void)refresh {
    
    __weak MyPredictionsViewController *weakSelf = self;
    
    _isRefreshing = YES;
    
    HistoryMyPredictionsRequest* request = [[HistoryMyPredictionsRequest alloc] init];    
    [self executeRequest:request withBlock:^{
        MyPredictionsViewController *strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        if (request.errorCode == 0)
        {
            strongSelf.predictions = [NSMutableArray arrayWithArray: request.predictions];
            [strongSelf.tableView reloadData];
            
            if ([strongSelf.predictions count] > 0) {
                [strongSelf.noContentView removeFromSuperview];
            }
            else {
                [strongSelf.view addSubview:strongSelf.noContentView];
            }
        }
        strongSelf->_isRefreshing = NO;
        if(strongSelf->_needLoadNextPage && strongSelf.predictions.count >= [HistoryMyPredictionsRequest limitByPage]) {
            [strongSelf loadNextPage];
        }
        strongSelf->_needLoadNextPage = NO;
    }];
}

- (void)loadNextPage {
    __weak MyPredictionsViewController *weakSelf = self;
    
    HistoryMyPredictionsRequest* predictionsRequest = [[HistoryMyPredictionsRequest alloc] initWithLastCreatedDate: ((Prediction*)[self.predictions lastObject]).creationDate];
    [self executeRequest:predictionsRequest withBlock:^{
        MyPredictionsViewController *strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        if (predictionsRequest.errorCode == 0 && predictionsRequest.predictions.count != 0)
        {
            [strongSelf.predictions addObjectsFromArray: [NSMutableArray arrayWithArray: predictionsRequest.predictions] ];
            [strongSelf.tableView reloadData];
        }
        else
        {
            [strongSelf.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: strongSelf.predictions.count - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:kPredictionDetailsSegue]) {
        PredictionDetailsViewController *vc = (PredictionDetailsViewController *)segue.destinationViewController;
        vc.prediction = sender;
        vc.addPredictionDelegate = self;
        vc.delegate = self;
    }
    else if([segue.identifier isEqualToString:kMyProfileSegue]) {
        ProfileViewController *vc = (ProfileViewController *)segue.destinationViewController;
        vc.leftButtonItemReturnsBack = YES;
    }
}

- (NSInteger)limitByPage {
    return [HistoryMyPredictionsRequest limitByPage];
}

#pragma mark - UITableViewDataSource


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return (self.predictions.count != 0) ? ((self.predictions.count >= [HistoryMyPredictionsRequest limitByPage]) ? self.predictions.count + 1 : self.predictions.count) : 1;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* tableCell;
    
    if (indexPath.row != self.predictions.count)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        
        PreditionCell* cell = [tableView dequeueReusableCellWithIdentifier:[PreditionCell reuseIdentifier]];
        cell.delegate = self;
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]init];
        [cell setUpUserProfileTapGestures:tapGesture];
        
        [cell fillWithPrediction: prediction];
        
        tableCell = cell;
    }
    else
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"LoadingCell"];
        tableCell = cell;
    }
    
    return tableCell;
}


#pragma mark - UITableViewDelegate


- (void) tableView: (UITableView*) tableView willDisplayCell: (UITableViewCell*) cell forRowAtIndexPath: (NSIndexPath*) indexPath
{
    if ((self.predictions.count >= [HistoryMyPredictionsRequest limitByPage]) && indexPath.row == self.predictions.count)
    {
        if(!_isRefreshing) {
            [self loadNextPage];
        }
        else {
            _needLoadNextPage = YES;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.predictions.count != 0)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
    }
}


#pragma mark - AddPredictionViewControllerDelegate

- (void) predictionWasMadeInController:(AddPredictionViewController *)vc {
    [vc dismissViewControllerAnimated:YES completion:nil];
    [self refresh];
}

#pragma mark - PredictionCellDelegate

- (void) profileSelectedWithUserId:(NSInteger)userId inCell:(PreditionCell *)cell {
    [self performSegueWithIdentifier:kMyProfileSegue sender:self];
}

#pragma mark PredictionDetailsDelegate

- (void)updatePrediction:(Prediction *)prediction {
    __weak MyPredictionsViewController *weakSelf = self;
    PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:prediction.ID];
    [self executeRequest:updateRequest withBlock:^{
        MyPredictionsViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if(updateRequest.isSucceeded) {
            [prediction updateWithObject:updateRequest.prediction];
            NSUInteger idx = [strongSelf.predictions indexOfObject:prediction];
            if(idx != NSNotFound) {
                [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
}

@end
