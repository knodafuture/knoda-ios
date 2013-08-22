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

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";

@interface MyPredictionsViewController () <AddPredictionViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray* predictions;
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


- (void) viewWillDisappear: (BOOL) animated
{
    self.cellUpdateTimer = nil;
    
    [super viewWillDisappear: animated];
}


- (void) updateVisibleCells
{
    NSArray* visibleCells = [self.tableView visibleCells];
    
    for (PreditionCell* cell in visibleCells)
    {
        [cell updateDates];
    }
}

- (void)refresh {
    HistoryMyPredictionsRequest* request = [[HistoryMyPredictionsRequest alloc] init];
    [request executeWithCompletionBlock: ^
     {
         if (request.errorCode == 0)
         {
             self.predictions = [NSMutableArray arrayWithArray: request.predictions];
             [self.tableView reloadData];
         }
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:kPredictionDetailsSegue]) {
        PredictionDetailsViewController *vc = (PredictionDetailsViewController *)segue.destinationViewController;
        vc.prediction = sender;
        vc.addPredictionDelegate = self;
    }
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
        HistoryMyPredictionsRequest* predictionsRequest = [[HistoryMyPredictionsRequest alloc] initWithLastCreatedDate: ((Prediction*)[self.predictions lastObject]).creationDate];
        [predictionsRequest executeWithCompletionBlock: ^
         {
             if (predictionsRequest.errorCode == 0 && predictionsRequest.predictions.count != 0)
             {
                 [self.predictions addObjectsFromArray: [NSMutableArray arrayWithArray: predictionsRequest.predictions] ];
                 [self.tableView reloadData];
             }
             else
             {
                 [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
             }
         }];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
    [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
}


#pragma mark - AddPredictionViewControllerDelegate

- (void) predictionWasMadeInController:(AddPredictionViewController *)vc {
    [vc dismissViewControllerAnimated:YES completion:nil];
    [self refresh];
}

@end
