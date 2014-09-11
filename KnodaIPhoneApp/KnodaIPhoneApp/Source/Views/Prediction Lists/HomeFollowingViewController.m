//
//  HomeFollowingViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "HomeFollowingViewController.h"
#import "WebApi.h"
#import "UserManager.h"

@interface HomeFollowingViewController ()

@end

@implementation HomeFollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([UserManager sharedInstance].user.followingCount == 0) {
        UITableViewCell *cell = [[[UINib nibWithNibName:@"NoSocialPredictionsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
        [self showNoContent:cell];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginRefreshing) name:UserChangedNotificationName object:nil];

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
- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object predictionId];
    [[WebApi sharedInstance] getSocialFeedAfter:lastId completion:completionHandler];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    
    UITableViewCell *cell = nil;
    if ([UserManager sharedInstance].user.followingCount == 0)
        cell = [[[UINib nibWithNibName:@"NoSocialPredictionsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    else
        cell = [[[UINib nibWithNibName:@"NoSocialPredictionsV2" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    [self showNoContent:cell];
}

@end
