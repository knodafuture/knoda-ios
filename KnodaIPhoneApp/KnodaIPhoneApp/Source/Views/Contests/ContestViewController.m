//
//  ContestViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "ContestViewController.h"
#import "Contest.h"
#import "WebApi.h"
#import "ContestNoContentCell.h"
#import "NavigationViewController.h"
#import "ContestTableViewCell.h"
#import "ContestDetailsViewController.h"
#import "ContestWalkthroughController.h"
#import "ContestDetailsTableViewController.h"
#import "ContestRankingsViewController.h"
#import "ContestRankingsTableViewController.h"
#import "SingleContestRankingsViewController.h"

@interface ContestViewController () <ContestTableViewCellDelegate>
@property (assign, nonatomic) BOOL shouldShowDetails;
@end

@implementation ContestViewController

- (id)initWithDetails:(BOOL)shouldShowDetails {
    self = [super initWithStyle:UITableViewStylePlain];
    self.shouldShowDetails = shouldShowDetails;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.scrollsToTop = NO;
    
    self.title = @"EXPLORE";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    
    self.tableView.backgroundColor = [UIColor colorFromHex:@"efefef"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginRefreshing) name:ContestVotingEvent object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return [ContestTableViewCell heightForContest:self.pagingDatasource.objects[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    
    
    Contest *contest = self.pagingDatasource.objects[indexPath.row];
    
    ContestTableViewCell *cell = [ContestTableViewCell cellForTableView:tableView];
    
    [cell populateWithContest:contest explore:self.shouldShowDetails];
    
    cell.contestImageView.image = [_imageLoader lazyLoadImage:contest.image.big onIndexPath:indexPath];
    
    if (indexPath.row == self.pagingDatasource.objects.count - 1)
        cell.seperatorView.hidden = YES;
    else
        cell.seperatorView.hidden = NO;
    
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.pagingDatasource.objects.count)
        return;
    
    Contest *contest = self.pagingDatasource.objects[indexPath.row];
    ContestDetailsViewController *vc = [[ContestDetailsViewController alloc] initWithContest:contest];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    Contest *contest = (Contest *)object;
    
    if (self.shouldShowDetails)
        [[WebApi sharedInstance] getMyContestsAfter:contest.contestId.integerValue completion:completionHandler];
    else
        [[WebApi sharedInstance] getExploreContestsAfter:contest.contestId.integerValue completion:completionHandler];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    ContestNoContentCell *cell = [ContestNoContentCell cellWithMessage:@"You're not participating in any contests, let's change that. Tap the compass icon (top right) to find new contests awaiting your votes"];
    [self showNoContent:cell];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    ContestTableViewCell *cell = (ContestTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:ContestTableViewCell.class])
        return;
    
    if (image)
        cell.contestImageView.image = image;
}

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController {
//    [self.pagingDatasource loadPage:0 completion:^{
//        [self.tableView reloadData];
//    }];
}

- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController {}

- (void)rankingsSelectedInTableViewCell:(ContestTableViewCell *)cell {
    
    if (cell.contest.contestStages.count > 0) {
        ContestRankingsViewController *vc = [[ContestRankingsViewController alloc] initWithContest:cell.contest];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        SingleContestRankingsViewController *vc = [[SingleContestRankingsViewController alloc] initWithContest:cell.contest];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
