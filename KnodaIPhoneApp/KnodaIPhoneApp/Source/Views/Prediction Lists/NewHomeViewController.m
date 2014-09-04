//
//  NewHomeViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NewHomeViewController.h"
#import "HomeViewController.h"
#import "HomeHeaderView.h"
#import "SocialInvitationsViewController.h" 
#import "SearchViewController.h"
#import "PredictionsViewController.h"
#import "HomeFollowingViewController.h"

@interface NewHomeViewController () <HomeHeaderViewDelegate>
@property (strong, nonatomic) PredictionsViewController *leftViewController;
@property (strong, nonatomic) PredictionsViewController *rightViewController;
@property (strong, nonatomic) HomeHeaderView *headerView;
@end

@implementation NewHomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftBarButtonItemWithImage:[UIImage imageNamed:@"FindFriendsIcon"] target:self action:@selector(invite)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"NavSearchIcon"] target:self action:@selector(search)];
    self.scrollView.scrollsToTop = NO;
    
    self.scrollView.scrollEnabled = NO;
    self.headerView = [[HomeHeaderView alloc] initWithDelegate:self firstName:@"VIEW ALL" secondName:@"FOLLOWING"];
    
    self.leftViewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
    self.rightViewController = [[HomeFollowingViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.navigationItem.titleView = self.headerView;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect frame = self.leftViewController.view.frame;
    frame.size.height = self.scrollView.frame.size.height;
    frame.origin.y = 0;
    self.leftViewController.view.frame = frame;
    
    [self addChildViewController:self.leftViewController];
    
    [self.scrollView addSubview:self.leftViewController.view];
    
    frame = self.rightViewController.view.frame;
    frame.origin.x = self.view.frame.size.width;
    frame.size.height = self.scrollView.frame.size.height;
    frame.origin.y = 0;
    self.rightViewController.view.frame = frame;
    
    [self addChildViewController:self.rightViewController];
    
    [self.scrollView addSubview:self.rightViewController.view];
    
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2.0, self.scrollView.frame.size.height);
}

- (void)invite {
    
    SocialInvitationsViewController *vc = [[SocialInvitationsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    
}
- (void)search {
    SearchViewController *vc = [[SearchViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)leftSideTappedInHeaderView:(HomeHeaderView *)headerView {
    self.leftViewController.tableView.scrollsToTop = YES;
    self.rightViewController.tableView.scrollsToTop = NO;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)rightSideTappedInHeaderView:(HomeHeaderView *)headerView {
    self.leftViewController.tableView.scrollsToTop = NO;
    self.rightViewController.tableView.scrollsToTop = YES;
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
}

- (UITableView *)tableView {
    if (self.scrollView.contentOffset.x > 0)
        return self.rightViewController.tableView;
    else
        return self.leftViewController.tableView;
}

@end
