//
//  TermsOfServiceViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "TermsOfServiceViewController.h"

@interface TermsOfServiceViewController ()

@end

@implementation TermsOfServiceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (IBAction) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}


/*- (void) viewWillAppear: (BOOL) animated
{
    self.navigationController.navigationBarHidden = NO;
    
    [super viewWillAppear: animated];
}


- (void) viewWillDisappear: (BOOL) animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillDisappear: animated];
}*/


@end
