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


@interface AllAlertsViewController ()

@property (nonatomic, strong) NSArray* alerts;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end

@implementation AllAlertsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    AllAlertsWebRequest* request = [[AllAlertsWebRequest alloc] init];
    [request executeWithCompletionBlock: ^
    {
        if (request.errorCode == 0)
        {
            NSLog(@"All alerts: %@", request.predictions);
            
            self.alerts = request.predictions;
            [self.tableView reloadData];
            
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
    }];
}


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return (self.alerts.count == 0) ? 1 : self.alerts.count;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* cell = nil;
    
    if (self.alerts.count != 0)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier: [AlertCell reuseIdentifier]];
        [((AlertCell*)cell) fillWithPrediction: [self.alerts objectAtIndex: indexPath.row]];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier: @"LoadingCell"];
    }
    
    return cell;
}


- (void) scrollViewDidEndScrollingAnimation: (UIScrollView*) scrollView
{
    if (self.alerts.count != 0)
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


@end
