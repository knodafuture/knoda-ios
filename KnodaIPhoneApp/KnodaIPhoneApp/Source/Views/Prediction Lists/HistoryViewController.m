//
//  MyPredictionsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HistoryViewController.h"
#import "PredictionCell.h"
#import "PredictionDetailsViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "LoadingCell.h"
#import "NavigationViewController.h"
#import "NoContentCell.h"
#import "WebApi.h"
#import "NoContentCell.h"

@interface HistoryViewController ()
@end


@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"HISTORY";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem sideNavBarBUttonItemwithTarget:self action:@selector(menuPressed:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
}
- (void)menuPressed:(id)sender {
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [Flurry logEvent: @"My_Predictions_Screen" withParameters: nil timed: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [Flurry endTimedEvent: @"My_Predictions_Screen" withParameters: nil];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object predictionId];
    [[WebApi sharedInstance] getHistoryAfter:lastId completion:completionHandler];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    [super noObjectsRetrievedInPagingDatasource:pagingDatasource];
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"Make your first prediction or vote." forTableView:self.tableView];
    
    [self showNoContent:cell];
}

@end
