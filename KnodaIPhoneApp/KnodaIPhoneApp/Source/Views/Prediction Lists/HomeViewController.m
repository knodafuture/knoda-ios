//
//  HomeViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HomeViewController.h"
#import "NavigationViewController.h"
#import "ProfileViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "AppDelegate.h"
#import "FirstStartView.h"
#import "UserManager.h"
#import "SearchViewController.h"
#import "WalkthroughController.h"   
#import "UIView+Utils.h"
#import "SocialInvitationsViewController.h"

NSString *HomeViewLoadedNotificationName = @"HOMEVIEWLOADED";
NSString *HomeViewCaptureKey = @"HOMEVIEWCAPUTRE";

@interface HomeViewController () <NavigationViewControllerDelegate>
@property (strong, nonatomic) WalkthroughController *walkthroughController;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"HOME";
    
    self.tableView.scrollsToTop = NO;
    
    self.walkthroughController = [[WalkthroughController alloc] initWithTargetViewController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginRefreshing) name:UserLoggedInNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(predictionVoted:) name:PredictionVotedEvent object:nil];
}

- (void)predictionVoted:(NSNotification *)notification {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        if (notification.userInfo[@"ViewController"] == self)
            return;
        Prediction *prediction = notification.userInfo[PredictionVotedKey];
        
        for (Prediction *oldPrediction in self.pagingDatasource.objects) {
            if (prediction.predictionId == oldPrediction.predictionId)
                oldPrediction.challenge = prediction.challenge;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
        });
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];    
    [Flurry logEvent: @"Home_Screen" withParameters: nil timed: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent: @"Home_Screen" withParameters: nil];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return YES;
}
- (void)pagingDatasource:(PagingDatasource *)pagingDatasource willDisplayObjects:(NSArray *)objects {
    [super pagingDatasource:pagingDatasource willDisplayObjects:objects];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.pagingDatasource.currentPage == 0) {
            [self.walkthroughController beginShowingWalkthroughIfNeeded];
            [[NSNotificationCenter defaultCenter] postNotificationName:HomeViewLoadedNotificationName object:nil userInfo:nil];
        }
    });
}

- (void)predictionAgreed:(Prediction *)prediction inCell:(PredictionCell *) cell {
    [super predictionAgreed:prediction inCell:cell];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VotingWalkthroughCompleteNotificationName object:nil];
}

- (void)predictionDisagreed:(Prediction *)prediction inCell:(PredictionCell *) cell {
    [super predictionDisagreed:prediction inCell:cell];
    [[NSNotificationCenter defaultCenter] postNotificationName:VotingWalkthroughCompleteNotificationName object:nil];
}

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController {
    
}

- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController {
    
}

- (void)dealloc {
    [self removeAllObservations];
}
@end
