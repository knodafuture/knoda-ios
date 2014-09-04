//
//  CGViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "CGViewController.h"
#import "GroupsViewController.h"
#import "ContestViewController.h"
#import "NavigationViewController.h"
#import "CreateGroupViewController.h"

@implementation CGViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"CONTESTS";
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"ContestExploreIcon"] target:self action:@selector(exploreContests)];
    
    GroupsViewController *groups = [[GroupsViewController alloc] initWithStyle:UITableViewStylePlain];
    ContestViewController *contests = [[ContestViewController alloc] initWithDetails:YES];
    
    self.view.backgroundColor = [UIColor colorFromHex:@"efefef"];
    [self addViewController:contests title:@"My Contests"];
    [self addViewController:groups title:@"My Groups"];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (UITableView *)tableView {
    UIViewController *vc = [self.viewControllers objectAtIndex:self.activePage];
    
    if ([vc respondsToSelector:@selector(tableView)])
        return [(id)vc tableView];
    else
        return nil;
}

- (void)didMoveFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex {
    BaseTableViewController *previous = self.viewControllers[index];
    BaseTableViewController *next = self.viewControllers[newIndex];
    
    next.tableView.scrollsToTop = YES;
    previous.tableView.scrollsToTop = NO;
    
    if (newIndex == 0) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"ContestExploreIcon"] target:self action:@selector(exploreContests)];
        self.title = @"CONTESTS";
    } else {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"CreateGroupIcon"] target:self action:@selector(createGroup:)];
        self.title = @"GROUPS";
    }
}

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController {
    [self.viewControllers makeObjectsPerformSelector:@selector(beginRefreshing)];
}

- (void)exploreContests {
    
    ContestViewController *vc = [[ContestViewController alloc] initWithDetails:NO];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)createGroup:(id)sender {
    

    [Flurry logEvent: @"CREATE_GROUP_START"];
    
    CreateGroupViewController *vc = [[CreateGroupViewController alloc] initWithGroup:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [Flurry logEvent: @"CREATE_GROUP_SUCCESS"];
}
@end
