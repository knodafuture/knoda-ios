//
//  BaseTableViewController.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ImageLoader.h"
#import "WebApi.h"
#import "LoadingCell.h"
#import "EmptyDatasource.h"
#import "AppDelegate.h"

@interface BaseTableViewController ()
@property (strong, nonatomic) EmptyDatasource *emptyDatasource;
@property (strong, nonatomic) NSTimer *graceTimer;
@property (assign, nonatomic) BOOL refreshEnded;
@property (assign, nonatomic) BOOL appeared;
@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    
    self.emptyDatasource = [[EmptyDatasource alloc] init];
	self.tableView.backgroundColor = [UIColor whiteColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.showsVerticalScrollIndicator = YES;

	_imageLoader = [[ImageLoader alloc] initForTable:self.tableView delegate:self];
	
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    if (!self.pagingDatasource)
        self.pagingDatasource = [[PagingDatasource alloc] initWithTableView:self.tableView];
    
    self.pagingDatasource.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.appeared) {
        [self.pagingDatasource loadPage:0 completion:^{
            [self.tableView reloadData];
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewObjectNotification:) name:NewObjectNotification object:nil];
    }
    
    self.appeared = YES;
}

- (void)dealloc {
    [self.graceTimer invalidate];
    self.graceTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refresh {
    [_graceTimer invalidate];
    _graceTimer = nil;
    _graceTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onGraceTimerExpired:) userInfo:nil repeats:NO];
    _refreshEnded = NO;
    [self beginRefreshing];
}

- (void)endRefreshing {
    _refreshEnded = YES;
    if (!_graceTimer) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }
}

- (void)onGraceTimerExpired:(NSTimer *)graceTimer {
    [_graceTimer invalidate];
    _graceTimer = nil;
    if (_refreshEnded)
        [self endRefreshing];
}

- (void)beginRefreshing {
    self.pagingDatasource.currentPage = 0;
    [self.pagingDatasource loadPage:0 completion:^{
        [self endRefreshing];
    }];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)handleNewObjectNotification:(NSNotification *)notification {
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate)
		[_imageLoader loadVisibleAssets];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[_imageLoader loadVisibleAssets];
}


- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    completionHandler(nil, nil);
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    [self endRefreshing];
}

- (void)pagingDatasource:(PagingDatasource *)pagingDatasource willDisplayObjects:(NSArray *)objects {
    if ([self.tableView.dataSource isKindOfClass:EmptyDatasource.class])
        [self restoreContent];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.pagingDatasource tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pagingDatasource tableView:tableView numberOfRowsInSection:section];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.pagingDatasource numberOfSectionsInTableView:tableView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self.pagingDatasource tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.pagingDatasource tableView:tableView heightForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.pagingDatasource tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.pagingDatasource tableView:tableView cellForRowAtIndexPath:indexPath];
}


- (void)showNoContent:(UITableViewCell *)noContentCell {
    self.emptyDatasource.cell = noContentCell;
    self.tableView.delegate = self.emptyDatasource;
    self.tableView.dataSource = self.emptyDatasource;
    [self.tableView reloadData];
}

- (void)restoreContent {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}


@end
