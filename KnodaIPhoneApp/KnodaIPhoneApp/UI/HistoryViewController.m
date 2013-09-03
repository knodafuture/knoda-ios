//
//  HistoryViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HistoryViewController.h"
#import "NavigationViewController.h"
#import "AddPredictionViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:5 forBarMetrics:UIBarMetricsDefault];
    
    [self performSegueWithIdentifier: @"MyPredictionSegue" sender: self];
}

- (IBAction) menuButtonPressed: (id) sender
{
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

@end
