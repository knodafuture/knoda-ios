//
//  GroupPredictionsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "GroupPredictionsViewController.h"
#import "Group.h"
#import "Prediction+Utils.h"
#import "WebApi.h"
#import "NoContentCell.h"
#import "GroupSettingsViewController.h"
#import "RankingsViewController.h"
#import "CreateGroupViewController.h"
#import "AppDelegate.h"

@interface GroupPredictionsViewController ()
@property (strong, nonatomic) Group *group;
@property (weak, nonatomic) IBOutlet UILabel *leaderNameLabel;
@property (strong, nonatomic) UITableViewCell *headerCell;
@end

@implementation GroupPredictionsViewController

- (id)initWithGroup:(Group *)group {
    self = [super initWithStyle:UITableViewStylePlain];
    self.group = group;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem backButtonWithTarget:self action:@selector(back)]];
    
    self.headerCell = [[[UINib nibWithNibName:@"GroupPredictionsHeaderCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] firstObject];
    [self populate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:GroupChangedNotificationName object:nil];
}

- (void)populate {
    self.title = self.group.name.uppercaseString;
    self.leaderNameLabel.text = self.group.leader.username;

}

- (void)back {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)groupChanged:(NSNotification *)notification {
    Group *changedGroup = [notification.userInfo objectForKey:GroupChangedNotificationKey];
    
    if (changedGroup.groupId == self.group.groupId) {
        [self populate];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [Flurry logEvent: @"Group_Prediction_List" withParameters: nil timed: YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ActiveGroupChangedNotificationName object:nil userInfo:@{ActiveGroupNotificationKey: self.group}];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent: @"Group_Prediction_list" withParameters: nil];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object predictionId];
    [[WebApi sharedInstance] getPredictionsForGroup:self.group.groupId after:lastId completion:completionHandler];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    [super noObjectsRetrievedInPagingDatasource:pagingDatasource];
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"No predictions right now." forTableView:self.tableView];
    
    self.tableView.tableHeaderView = self.headerCell;
    [self showNoContent:cell];
}
- (void)restoreContent {
    self.tableView.tableHeaderView = nil;
    [super restoreContent];
}

- (void)handleNewObjectNotification:(NSNotification *)notification {
    Prediction *prediction = [notification.userInfo objectForKey:NewPredictionNotificationKey];
    
    if (prediction.groupId != self.group.groupId)
        return;
    
    [self.pagingDatasource insertNewObject:prediction atIndex:0 reload:YES];
    
    if (self.tableView.dataSource != self.pagingDatasource)
        [self restoreContent];
}

- (IBAction)rankingsPressed:(id)sender {
    RankingsViewController *vc = [[RankingsViewController alloc] initWithGroup:self.group];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)settingsPressed:(id)sender {
    GroupSettingsViewController *vc = [[GroupSettingsViewController alloc] initWithGroup:self.group];
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    if (indexPath.section == 0)
        return;
    
    Prediction *prediction = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
    vc.delegate = self;
    vc.shouldNotOpenCategory = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return;
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
}
@end
