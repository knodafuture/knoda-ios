//
//  BaseRequestingViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 03.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseRequestingViewController.h"
#import "NavigationViewController.h"

@interface BaseRequestingViewController ()

@property (nonatomic) NSMutableArray *webRequests;

@end

@implementation BaseRequestingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webRequests = [NSMutableArray array];
    
//    self.navigationController.navigationBar.translucent = NO;
//    
//    if (self.navigationController && self.navigationController.viewControllers.count > 1)
//        self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backButtonPressed:)];
//    else
//        self.navigationItem.leftBarButtonItem = [UIBarButtonItem sideNavBarBUttonItemwithTarget:self action:@selector(menuPressed:)];
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
}

- (NSMutableArray *)getWebRequests {
    return self.webRequests;
}

- (void)menuPressed:(id)sender {
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}
- (void)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
