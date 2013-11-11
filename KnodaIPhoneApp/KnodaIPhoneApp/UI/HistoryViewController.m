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

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";


@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performSegueWithIdentifier: @"MyPredictionSegue" sender: self];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem sideNavBarBUttonItemwithTarget:self action:@selector(menuButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"PredictIcon"] target:self action:@selector(createPredictionPressed:)];
    self.navigationController.navigationBar.translucent = NO;
}

- (IBAction) menuButtonPressed: (id) sender
{
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

- (void)createPredictionPressed:(id)sender {
    [self performSegueWithIdentifier:kAddPredictionSegue sender:sender];
}

@end
