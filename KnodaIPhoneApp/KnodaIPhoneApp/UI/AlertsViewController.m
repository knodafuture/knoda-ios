//
//  AlertsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AlertsViewController.h"
#import "NavigationViewController.h"
#import "AllAlertsWebRequest.h"

@interface AlertsViewController ()

@end

@implementation AlertsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:5 forBarMetrics:UIBarMetricsDefault];
    [self performSegueWithIdentifier: @"AllAlertsSegue" sender: self];
}

- (void) setUpNoContentViewHidden: (BOOL) hidden {
    if (self.noContentView.hidden == hidden) {
        return;
    }
    self.noContentView.hidden = hidden;
    if (hidden) {
        [self.noContentView removeFromSuperview];
    }
    else {
        [self.view addSubview:self.noContentView];
    }
}


- (IBAction) menuButtonPressed: (id) sender
{
    if (self.childViewControllers.count > 0) {
        [(UIViewController<RefreshableViewController>*)[self.childViewControllers objectAtIndex: 0] refresh];
    }
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

@end
