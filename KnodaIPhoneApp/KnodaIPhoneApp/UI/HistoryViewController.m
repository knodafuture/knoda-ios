//
//  HistoryViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "HistoryViewController.h"
#import "NavigationSegue.h"
#import "NavigationViewController.h"


@interface HistoryViewController ()

@property (nonatomic, strong) IBOutlet UIView* detailsView;
@property (nonatomic, strong) IBOutlet UIImageView* segmentedControlImage;

@end


@implementation HistoryViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
	
    [self performSegueWithIdentifier: @"MyPredictionSegue" sender: self];
}


- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    ((NavigationSegue*)segue).detailsView = self.detailsView;
}


- (IBAction) menuButtonPressed: (id) sender
{
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}


- (IBAction) lerfButtonPressed: (id) sender
{
    self.segmentedControlImage.image = [UIImage imageNamed: @"sort_left-green"];
}


- (IBAction) rightButtonPressed: (id) sender
{
    self.segmentedControlImage.image = [UIImage imageNamed: @"sort_right-green"];
}


@end
