//
//  AllAlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AllAlertsViewController.h"

#import "AllAlertsWebRequest.h"
#import "Challenge.h"
#import "Prediction.h"
#import "SetSeenAlertsWebRequest.h"
#import "PredictionDetailsViewController.h"
#import "PredictionCell.h"
#import "LoadingCell.h"
#import "NavigationViewController.h"
#import "AppDelegate.h" 
#import "ProfileViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "NoContentCell.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";
static NSString* const kMyProfileSegue = @"MyProfileSegue";
static NSString* const kUserProfileSegue       = @"UserProfileSegue";

@interface AllAlertsViewController ()
@property (strong, nonatomic) NSMutableArray *predictions;
@property (strong, nonatomic) NSMutableArray *webRequests;
@property (assign, nonatomic) BOOL loading;
@end

@implementation AllAlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem sideNavBarBUttonItemwithTarget:self action:@selector(menuPressed:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
    self.title = @"ALERTS";
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget: self action: @selector(refresh:) forControlEvents: UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}
- (NSMutableArray *)getWebRequests {
    return self.webRequests;
}
- (void)menuPressed:(id)sender {
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}
- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self refresh:nil];
    [Flurry logEvent: @"All_Alerts_Screen" withParameters: nil timed: YES];
    }


- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"All_Alerts_Screen" withParameters: nil];
}


- (void)refresh:(UIRefreshControl *)refresh {
    
    __weak AllAlertsViewController *weakSelf = self;
    self.loading = YES;

    AllAlertsWebRequest* request = [[AllAlertsWebRequest alloc] init];
    
    [self executeRequest:request withBlock:^{
        AllAlertsViewController *strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        self.loading = NO;
        
        [refresh endRefreshing];
        if (request.errorCode == 0)
        {
            
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
                [self.tableView reloadData];
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
    else if([segue.identifier isEqualToString:kUserProfileSegue]) {
        AnotherUsersProfileViewController *vc = (AnotherUsersProfileViewController *)segue.destinationViewController;
        vc.userId = [sender integerValue];
    }
    else if([segue.identifier isEqualToString:kMyProfileSegue]) {
        ProfileViewController *vc = (ProfileViewController *)segue.destinationViewController;
        vc.leftButtonItemReturnsBack = YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.loading && self.predictions.count == 0)
        return self.tableView.frame.size.height;
    
    if (indexPath.row != self.predictions.count)
        return [PredictionCell heightForPrediction:[self.predictions objectAtIndex:indexPath.row]];
    else
        return loadingCellHeight;
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
        cell.delegate = self;
        return cell;
    }
    else if (self.loading)
        return [LoadingCell loadingCellForTableView:tableView];
    else
        return [NoContentCell noContentWithMessage:@"No alerts right now." forTableView:tableView height:self.tableView.frame.size.height];
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
- (void) profileSelectedWithUserId:(NSInteger)userId inCell:(PredictionCell *)cell {
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] user].userId == userId)
        [self performSegueWithIdentifier:kMyProfileSegue sender:self];
    else
        [self performSegueWithIdentifier:kUserProfileSegue sender:[NSNumber numberWithInt:userId]];
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
