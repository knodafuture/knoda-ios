//
//  BadgesViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BadgesViewController.h"
#import "NavigationViewController.h"

@interface BadgesViewController ()

@end

@implementation BadgesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
}


- (IBAction) menuButtonPressed: (id) sender
{
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}


@end
