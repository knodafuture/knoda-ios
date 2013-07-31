//
//  TermsOfServiceViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "TermsOfServiceViewController.h"

@interface TermsOfServiceViewController ()

@property (nonatomic, strong) IBOutlet UIView* activityView;
@property (nonatomic, strong) IBOutlet UIWebView* webView;

@end

@implementation TermsOfServiceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void) viewWillAppear: (BOOL) animated
{
    //self.activityView.hidden = NO;
    
    [self.webView loadHTMLString: @"<html><body><h2 align='center'>Terms of Service</h2><p>Will be placed here</p></body></html>" baseURL: nil];
    
    [super viewWillAppear: animated];
}


- (IBAction) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}


@end
