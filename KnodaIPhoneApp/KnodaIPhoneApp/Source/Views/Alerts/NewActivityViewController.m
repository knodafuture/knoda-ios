//
//  NewActivityViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 6/22/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NewActivityViewController.h"
#import "ActivityViewController.h"
#import "NavigationViewController.h"

@interface NewActivityViewController () <NavigationViewControllerDelegate>
@end

@implementation NewActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"ACTIVITY";
    
    
    ActivityViewController *allActivityItems = [[ActivityViewController alloc] initWithFilter:nil];
    ActivityViewController *expiredItems = [[ActivityViewController alloc] initWithFilter:@"expired"];
    ActivityViewController *commentItems = [[ActivityViewController alloc] initWithFilter:@"comments"];
    ActivityViewController *inviteItems = [[ActivityViewController alloc] initWithFilter:@"invites"];
    
    
    [self addViewController:allActivityItems title:@"All"];
    [self addViewController:expiredItems title:@"Expired"];
    [self addViewController:commentItems title:@"Comments"];
    [self addViewController:inviteItems title:@"Invites"];
    
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
    ActivityViewController *previous = self.viewControllers[index];
    ActivityViewController *next = self.viewControllers[newIndex];
    
    next.tableView.scrollsToTop = YES;
    previous.tableView.scrollsToTop = NO;
}

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController {
    if (viewController.unseenAlertsCount == 0)
        [self.viewControllers makeObjectsPerformSelector:@selector(beginRefreshing)];
    else
        [self.viewControllers[0] beginRefreshing];
    viewController.unseenAlertsCount = 0;
}

- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController {
    
}
@end
