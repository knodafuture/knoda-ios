//
//  AllAlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AllAlertsViewController.h"

#import "AllAlertsWebRequest.h"
#import "Chellange.h"
#import "Prediction.h"
#import "SetSeenAlertsWebRequest.h"
#import "PredictionDetailsViewController.h"
#import "PredictionCell.h"
#import "LoadingCell.h"
#import "NavigationViewController.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";

@interface AllAlertsViewController ()
@property (strong, nonatomic) NSMutableArray *predictions;
@end

@implementation AllAlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem sideNavBarBUttonItemwithTarget:self action:@selector(menuPressed:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
    self.title = @"ALERTS";
}
- (void)menuPressed:(id)sender {
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}
- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self refresh];
    [Flurry logEvent: @"All_Alerts_Screen" withParameters: nil timed: YES];
    
    self.tableView.rowHeight = [PredictionCell cellHeight];
}


- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"All_Alerts_Screen" withParameters: nil];
}


- (void)refresh {
    
    __weak AllAlertsViewController *weakSelf = self;
    
    AllAlertsWebRequest* request = [[AllAlertsWebRequest alloc] init];
    
    [self executeRequest:request withBlock:^{
        AllAlertsViewController *strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        if (request.errorCode == 0)
        {
            NSLog(@"All alerts: %@", request.predictions);
            
            strongSelf.predictions = [NSMutableArray arrayWithArray:request.predictions];
            [strongSelf.tableView reloadData];
            
            if (strongSelf.predictions.count != 0)
            {
                NSArray* visibleCells = [strongSelf.tableView visibleCells];
                NSMutableArray* chellangeIDs = [NSMutableArray arrayWithCapacity: 0];
                
                for (PredictionCell* cell in visibleCells)
                {
                    if (cell.prediction.settled)
                    {
                        [chellangeIDs addObject: [NSNumber numberWithInteger: cell.prediction.chellange.ID]];
                    }
                }
                
                if (chellangeIDs.count != 0)
                {
                    SetSeenAlertsWebRequest* request = [[SetSeenAlertsWebRequest alloc] initWithIDs: chellangeIDs];
                    [request executeWithCompletionBlock: ^
                     {
                         if (request.errorCode != 0)
                         {
                             for (PredictionCell* cell in visibleCells)
                             {
                                 cell.prediction.chellange.seen = YES;
                             }
                         }
                     }];
                }
            }
            else {
                strongSelf.noContentView.hidden = NO;
            }
        }
    }];
}

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if([segue.identifier isEqualToString: kPredictionDetailsSegue]) {
        PredictionDetailsViewController *vc = (PredictionDetailsViewController *)segue.destinationViewController;
        vc.prediction = sender;
    }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return (self.predictions.count == 0) ? 1 : self.predictions.count;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    if (self.predictions.count != 0)
    {
        PredictionCell *cell = [PredictionCell predictionCellForTableView:tableView];
        [cell fillWithPrediction:[self.predictions objectAtIndex:indexPath.row]];
        return cell;
    }
    else
        return [LoadingCell loadingCellForTableView:tableView];
}


- (void) scrollViewDidEndScrollingAnimation: (UIScrollView*) scrollView
{
    if (self.predictions.count != 0)
    {
        NSArray* visibleCells = [self.tableView visibleCells];
        NSMutableArray* chellangeIDs = [NSMutableArray arrayWithCapacity: 0];
        
        for (PredictionCell* cell in visibleCells)
        {
            if (cell.prediction.settled)
            {
                [chellangeIDs addObject: [NSNumber numberWithInteger: cell.prediction.chellange.ID]];
            }
        }
        
        if (chellangeIDs.count != 0)
        {
            SetSeenAlertsWebRequest* request = [[SetSeenAlertsWebRequest alloc] initWithIDs: chellangeIDs];
            [request executeWithCompletionBlock: ^
            {
                if (request.errorCode != 0)
                {
                    for (PredictionCell* cell in visibleCells)
                    {
                        cell.prediction.chellange.seen = YES;
                    }
                }
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if (self.predictions.count != 0)
    {
        Prediction* prediction = [self.predictions objectAtIndex: indexPath.row];
        [self performSegueWithIdentifier:kPredictionDetailsSegue sender:prediction];
    }
}

@end
