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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:GroupChangedNotificationName object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pagingDatasource loadPage:0 completion:^{
        [self.tableView reloadData];
    }];
}

- (void)groupChanged:(NSNotification *)notification {
    [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {
        [self.pagingDatasource loadPage:0 completion:^{
            [self.tableView reloadData];
        }];
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 48.0;
    
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
    
    if (indexPath.section == 0) {
        [self createGroup:nil];
        return;
    }
    if (indexPath.row == self.pagingDatasource.objects.count)
        return;


    Group *group = [UserManager sharedInstance].groups[indexPath.row];
    
    GroupPredictionsViewController *vc = [[GroupPredictionsViewController alloc] initWithGroup:group];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    completionHandler([UserManager sharedInstance].groups, nil);
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (IBAction)createGroup:(id)sender {
    [Flurry logEvent: @"Create_Group"];

    CreateGroupViewController *vc = [[CreateGroupViewController alloc] initWithGroup:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"You are not in any groups. Create a group with your friends to start making private predictions." forTableView:self.tableView];
    [self showNoContent:cell];
    
    self.createGroupsCell.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createGroup:)];
    [self.createGroupsCell addGestureRecognizer:tap];
    self.tableView.tableHeaderView = self.createGroupsCell;
    [self showNoContent:cell];
}
- (void)restoreContent {
    self.tableView.tableHeaderView = nil;
    self.createGroupsCell.userInteractionEnabled = NO;
    self.createGroupsCell.gestureRecognizers = nil;
    [super restoreContent];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    GroupTableViewCell *cell = (GroupTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:GroupTableViewCell.class])
        return;
    cell.groupImage.image = image;
}

@end
