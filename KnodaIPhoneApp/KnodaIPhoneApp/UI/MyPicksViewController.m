//
//  MyPicksViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "MyPicksViewController.h"
#import "PreditionCell.h"
#import "HistoryMyPicksWebRequest.h"
#import "Prediction.h"
#import "PredictionDetailsViewController.h"
#import "AnotherUsersProfileViewController.h"


static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";
static NSString* const kUserProfileSegue       = @"UserProfileSegue";

@interface MyPicksViewController () <PredictionCellDelegate>

@property (strong, nonatomic) IBOutlet UIView *noContentView;
@property (nonatomic, strong) NSMutableArray* predictions;
@property (nonatomic, strong) NSTimer* cellUpdateTimer;

@end


@implementation MyPicksViewController


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    [self refresh];
    
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
    
    __weak MyPicksViewController *weakSelf = self;
    
    HistoryMyPicksWebRequest* request = [[HistoryMyPicksWebRequest alloc] init];
    [request executeWithCompletionBlock: ^
     {
         MyPicksViewController *strongSelf = weakSelf;
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
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:kPredictionDetailsSegue]) {
        PredictionDetailsViewController *vc = (PredictionDetailsViewController *)segue.destinationViewController;
        vc.prediction = sender;
    }
    else if([segue.identifier isEqualToString:kUserProfileSegue]) {
        AnotherUsersProfileViewController *vc = (AnotherUsersProfileViewController *)segue.destinationViewController;
        vc.userId = [sender integerValue];
    }
}


#pragma mark - UITableViewDataSource


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return (self.predictions.count != 0) ? ((self.predictions.count >= [HistoryMyPicksWebRequest limitByPage]) ? self.predictions.count + 1 : self.predictions.count) : 1;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* tableCell;
    
    if (indexPath.row != self.predictions.count)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        
        PreditionCell* cell = [tableView dequeueReusableCellWithIdentifier:[PreditionCell reuseIdentifier]];
        cell.delegate = self;
        
        [cell fillWithPrediction: prediction];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]init];
        [cell setUpUserProfileTapGestures:tapGesture];
        
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
    if ((self.predictions.count >= [HistoryMyPicksWebRequest limitByPage]) && indexPath.row == self.predictions.count)
    {
        __weak MyPicksViewController *weakSelf = self;
        
        HistoryMyPicksWebRequest* predictionsRequest = [[HistoryMyPicksWebRequest alloc] initWithLastCreatedDate: ((Prediction*)[self.predictions lastObject]).creationDate];
        [predictionsRequest executeWithCompletionBlock: ^
         {
             MyPicksViewController *strongSelf = weakSelf;
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
                 [strongSelf.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
             }
         }];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.predictions.count != 0)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
    }
}

#pragma mark - PredictionCellDelegate
- (void) profileSelectedWithUserId:(NSInteger)userId inCell:(PreditionCell *)cell {
    [self performSegueWithIdentifier:kUserProfileSegue sender:[NSNumber numberWithInteger:userId]];
}

@end
