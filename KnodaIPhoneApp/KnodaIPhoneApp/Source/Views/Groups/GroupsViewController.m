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

@interface GroupsViewController ()
@property (strong, nonatomic) UITableViewCell *createGroupsCell;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"GROUPS";
    self.view.backgroundColor = [UIColor colorFromHex:@"EFEFEF"];
    self.createGroupsCell = [[[UINib nibWithNibName:@"CreateGroupCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] firstObject];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pagingDatasource loadPage:0 completion:^{}];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 44.0;
    
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    return 86.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.createGroupsCell;
    }
    
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
    if (indexPath.section == 0) {
        [self createGroup:nil];
        return;
    }

    Group *group = [UserManager sharedInstance].groups[indexPath.row];
    
    GroupPredictionsViewController *vc = [[GroupPredictionsViewController alloc] initWithGroup:group];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    [[WebApi sharedInstance] getGroups:completionHandler];
}

- (IBAction)createGroup:(id)sender {
    CreateGroupViewController *vc = [[CreateGroupViewController alloc] initWithGroup:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    GroupTableViewCell *cell = (GroupTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:GroupTableViewCell.class])
        return;
    cell.groupImage.image = image;
}

@end
