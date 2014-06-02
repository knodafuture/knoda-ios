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
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [Flurry logEvent: @"HISTORY" withParameters: nil timed: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [Flurry endTimedEvent: @"HISTORY" withParameters: nil];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object challenge].challengeId;
    [[WebApi sharedInstance] getHistoryAfter:lastId completion:completionHandler];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    [super noObjectsRetrievedInPagingDatasource:pagingDatasource];
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"Make your first prediction or vote." forTableView:self.tableView];
    
    [self showNoContent:cell];
}

@end
