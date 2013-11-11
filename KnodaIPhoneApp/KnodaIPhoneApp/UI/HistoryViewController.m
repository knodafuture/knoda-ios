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
    
    [self performSegueWithIdentifier: @"MyPredictionSegue" sender: self];
}

- (IBAction) menuButtonPressed: (id) sender
{
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

@end
