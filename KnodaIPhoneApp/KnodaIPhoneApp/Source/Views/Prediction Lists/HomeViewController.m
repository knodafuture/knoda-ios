//
//  HomeViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HomeViewController.h"
#import "NavigationViewController.h"
#import "ProfileViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "AppDelegate.h"
#import "FirstStartView.h"
#import "UserManager.h"
#import "SearchViewController.h"

@interface HomeViewController () <NavigationViewControllerDelegate>
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"HOME";
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"NavSearchIcon"] target:self action:@selector(search)];
}


- (void)search {
    SearchViewController *vc = [[SearchViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];    
    [Flurry logEvent: @"Home_Screen" withParameters: nil timed: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent: @"Home_Screen" withParameters: nil];
}

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController {
    //[self appeared];
}

- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController {
    //[self disappeared];
}

@end
