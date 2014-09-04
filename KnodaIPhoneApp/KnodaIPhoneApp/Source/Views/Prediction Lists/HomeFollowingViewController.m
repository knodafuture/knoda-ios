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
}
- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object predictionId];
    [[WebApi sharedInstance] getSocialFeedAfter:lastId completion:completionHandler];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    UITableViewCell *cell = [[[UINib nibWithNibName:@"NoSocialPredictionsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    [self showNoContent:cell];
}

@end
