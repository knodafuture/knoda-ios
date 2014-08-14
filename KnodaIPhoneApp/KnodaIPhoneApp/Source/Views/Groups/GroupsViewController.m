//
//  GroupsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "GroupsViewController.h"
#import "WebApi.h"
#import "UserManager.h"
#import "GroupTableViewCell.h"
#import "GroupPredictionsViewController.h"
#import "CreateGroupViewController.h"
#import "NoContentCell.h"
#import "NavigationViewController.h"

@interface GroupsViewController () <NavigationViewControllerDelegate>

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GROUPS";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:GroupChangedNotificationName object:nil];
    
    self.tableView.scrollsToTop = NO;
    self.refreshControl.backgroundColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.backgroundColor = [UIColor colorFromHex:@"efefef"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)groupChanged:(NSNotification *)notification {
    [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {
        [self.pagingDatasource loadPage:0 completion:^{
            [self.tableView reloadData];
        }];
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    return 86.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    

    Group *group = self.pagingDatasource.objects[indexPath.row];
    
    GroupTableViewCell *cell = [GroupTableViewCell cellForTableView:tableView];
    cell.nameLabel.text = group.name;
    cell.leaderNameLabel.text = group.leader.username;
    cell.rankLabel.text = [NSString stringWithFormat:@"%ld", (long)group.rank];
    cell.rankDetailsLabel.text = [NSString stringWithFormat:@"rank (%ld)", (long)group.memberCount];
    
    cell.groupImage.image = [_imageLoader lazyLoadImage:group.avatar.small onIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.pagingDatasource.objects.count)
        return;


    Group *group = [UserManager sharedInstance].groups[indexPath.row];
    
    GroupPredictionsViewController *vc = [[GroupPredictionsViewController alloc] initWithGroup:group];
    [self.parentViewController.navigationController pushViewController:vc animated:YES];
    
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    completionHandler([UserManager sharedInstance].groups, nil);
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"You are not in any groups. Create a group with your friends to start making private predictions." forTableView:self.tableView];
    [self showNoContent:cell];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    GroupTableViewCell *cell = (GroupTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:GroupTableViewCell.class])
        return;
    cell.groupImage.image = image;
}

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController {
    [self.pagingDatasource loadPage:0 completion:^{
        [self.tableView reloadData];
    }];
}

- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController {}

@end
