//
//  MeTableViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/16/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "MeTableViewController.h"
#import "WebApi.h"
#import "UserProfileHeaderView.h"
#import "UserManager.h"
#import "NoContentCell.h"
#import "ProfileViewController.h"
#import "AnotherUsersProfileViewController.h"

@interface MeTableViewController ()
@property (assign, nonatomic) BOOL challenged;
@property (strong, nonatomic) UserProfileHeaderView *headerView;
@property (strong, nonatomic) UITableViewCell *headerCell;
@property (weak, nonatomic) id<MeTableViewControllerDelegate> delegate;
@end

@implementation MeTableViewController

- (id)initForChallenged:(BOOL)challenged delegate:(id<MeTableViewControllerDelegate>)delegate {
    self = [super initWithStyle:UITableViewStylePlain];
    self.challenged = challenged;
    self.delegate = delegate;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView = [[UserProfileHeaderView alloc] initWithDelegate:self.delegate];
    
    [self.headerView populateWithUser:[UserManager sharedInstance].user];
    self.headerCell = [[UITableViewCell alloc] init];
    self.headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.headerCell.frame = self.headerView.bounds;
    self.headerCell.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    CGRect frame = self.headerCell.frame;
    frame.size.height += 36;
    self.headerCell.frame = frame;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.headerCell addSubview:self.headerView];
    
    self.refreshControl.tintColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    UIView *refreshBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -self.refreshControl.frame.size.height * 5, self.view.frame.size.width, self.refreshControl.frame.size.height * 5)];
    refreshBackground.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    [self.tableView insertSubview:refreshBackground atIndex:0];
    self.tableView.scrollsToTop = NO;
    
    self.headerCell.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(predictionChanged:) name:PredictionChangedNotificationName object:nil];
    
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
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"No Predictions." forTableView:self.tableView height:self.view.frame.size.height - self.headerCell.frame.size.height];
    [self showNoContent:cell];
    self.tableView.tableHeaderView = self.headerCell;
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
    [[WebApi sharedInstance] getHistoryAfter:lastId challenged:self.challenged completion:completionHandler];
}

- (void)setHeaderHidden:(BOOL)hidden {
    self.headerView.hidden = hidden;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
