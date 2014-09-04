//
//  ContestDetailsTableViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/3/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestDetailsTableViewController.h"
#import "Contest.h"
#import "ContestTableViewCell.h"
#import "WebApi.h"
#import "NoContentCell.h"
#import "PredictionDetailsViewController.h"
#import "UserManager.h"
#import "AnotherUsersProfileViewController.h"
#import "ContestWalkthroughController.h"

NSString *ContestVotingEvent = @"CONTESTVOTINGEVENT";

@interface ContestDetailsTableViewController ()
@property (weak, nonatomic) id<ContestDetailsTableViewControllerDelegate>delegate;
@property (assign, nonatomic) BOOL expired;
@property (strong, nonatomic) ContestTableViewCell *headerCell;
@end

@implementation ContestDetailsTableViewController

- (id)initForContest:(Contest *)contest expired:(BOOL)expired delegate:(id<ContestDetailsTableViewControllerDelegate>)delegate {
    self = [super initWithStyle:UITableViewStylePlain];
    self.contest = contest;
    self.expired = expired;
    self.delegate = delegate;
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerCell = [[ContestTableViewCell alloc] initWithContest:self.contest Delegate:self.delegate];
    [[WebApi sharedInstance] getImage:self.contest.image.big completion:^(UIImage *image, NSError *error) {
        if (image)
            self.headerCell.contestImageView.image = image;
    }];
    self.headerCell.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.refreshControl.tintColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.backgroundColor = [UIColor clearColor];
    UIView *refreshBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -self.refreshControl.frame.size.height * 5, self.view.frame.size.width, self.refreshControl.frame.size.height * 5)];
    refreshBackground.backgroundColor = [UIColor colorFromHex:@"ffffff"];
    [self.tableView insertSubview:refreshBackground atIndex:0];
    self.tableView.scrollsToTop = NO;
    
    self.headerCell.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(predictionChanged:) name:PredictionChangedNotificationName object:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return 36.0;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
        return self.headerCell.frame.size.height;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return self.headerCell;
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"No Predictions right now, check back later." forTableView:self.tableView];
    [cell shiftDown:50];
    [self showNoContent:cell];
    self.tableView.tableHeaderView = self.headerCell.contentView;
    [self showNoContent:cell];
    

}
- (void)restoreContent {
    self.tableView.tableHeaderView = nil;
    [super restoreContent];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(tableViewDidScroll:inTableViewController:)])
        [self.delegate tableViewDidScroll:scrollView inTableViewController:self];
    
    UITableViewCell *stickyCell = self.headerCell;
    CGRect frame = stickyCell.frame;
    
    frame.origin.y = MAX(scrollView.contentOffset.y * 0.5, 0);
    
    stickyCell.frame = frame;
    
    [stickyCell.superview sendSubviewToBack:stickyCell];
    [stickyCell.superview sendSubviewToBack:self.refreshControl];
}

- (void)predictionChanged:(NSNotification *)notification {
    
    Prediction *prediction = notification.userInfo[PredictionChangedNotificationKey];
    NSInteger indexToExchange = NSNotFound;
    
    for (Prediction *oldPrediction in self.pagingDatasource.objects) {
        if (prediction.predictionId == oldPrediction.predictionId)
            indexToExchange = [self.pagingDatasource.objects indexOfObject:oldPrediction];
    }
    
    if (indexToExchange == NSNotFound)
        return;
    
    [self.pagingDatasource.objects replaceObjectAtIndex:indexToExchange withObject:prediction];
    [self.tableView reloadData];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object predictionId];
    
    [[WebApi sharedInstance] getPredictionsForContest:self.contest.contestId.integerValue after:lastId expired:self.expired completion:completionHandler];
}

- (void)setHeaderHidden:(BOOL)hidden {
    self.headerCell.contentView.hidden = hidden;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.pagingDatasource.objects.count || indexPath.section == 0)
        return;
    
    Prediction *prediction = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
    vc.delegate = self;
    
    [self.parentViewController.navigationController pushViewController:vc animated:YES];
    
}

- (void)profileSelectedWithUserId:(NSInteger)userId inCell:(PredictionCell *)cell {
    if (userId == [UserManager sharedInstance].user.userId) {
    } else {
        AnotherUsersProfileViewController *vc = [[AnotherUsersProfileViewController alloc] initWithUserId:userId];
        [self.parentViewController.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pagingDatasource:(PagingDatasource *)pagingDatasource willDisplayObjects:(NSArray *)objects {
    [super pagingDatasource:pagingDatasource willDisplayObjects:objects];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.pagingDatasource.currentPage == 0 && pagingDatasource.objects.count > 0)
            [self.delegate tableViewDidFinishLoadingInViewController:self];
    });
}

- (void)predictionAgreed:(Prediction *)prediction inCell:(PredictionCell *) cell {
    [[NSNotificationCenter defaultCenter] postNotificationName:ContestVoteWalkthroughCompleteNotificationName object:nil];

    [[WebApi sharedInstance] agreeWithPrediction:prediction.predictionId completion:^(Challenge *challenge, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ContestVotingEvent object:nil];

            prediction.challenge = challenge;
            [cell fillWithPrediction:prediction];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to agree at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
            
        }
    }];
}

- (void)predictionDisagreed:(Prediction *)prediction inCell:(PredictionCell *) cell {
    [[NSNotificationCenter defaultCenter] postNotificationName:ContestVoteWalkthroughCompleteNotificationName object:nil];
    [[WebApi sharedInstance] disagreeWithPrediction:prediction.predictionId completion:^(Challenge *challenge, NSError *error) {
        if (!error) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ContestVotingEvent object:nil];
            prediction.challenge = challenge;
            [cell fillWithPrediction:prediction];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to disagree at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
    }];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setContest:(Contest *)contest {
    _contest = contest;
    
    [self.headerCell populateWithContest:contest explore:NO];
}

@end
