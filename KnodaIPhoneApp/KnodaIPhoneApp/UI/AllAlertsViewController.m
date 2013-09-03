//
//  AllAlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AllAlertsViewController.h"

#import "AlertCell.h"
#import "AllAlertsWebRequest.h"

#import "Chellange.h"
#import "Prediction.h"

#import "SetSeenAlertsWebRequest.h"

#import "PredictionDetailsViewController.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";

@interface AllAlertsViewController ()

@end

@implementation AllAlertsViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refresh];
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
                
                for (PreditionCell* cell in visibleCells)
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
                             for (PreditionCell* cell in visibleCells)
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
    UITableViewCell* cell = nil;
    
    if (self.predictions.count != 0)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier: [AlertCell reuseIdentifier]];
        [((AlertCell*)cell) fillWithPrediction: [self.predictions objectAtIndex: indexPath.row]];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier: @"LoadingCell"];
    }
    
    return cell;
}


- (void) scrollViewDidEndScrollingAnimation: (UIScrollView*) scrollView
{
    if (self.predictions.count != 0)
    {
        NSArray* visibleCells = [self.tableView visibleCells];
        NSMutableArray* chellangeIDs = [NSMutableArray arrayWithCapacity: 0];
        
        for (PreditionCell* cell in visibleCells)
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
                    for (PreditionCell* cell in visibleCells)
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
