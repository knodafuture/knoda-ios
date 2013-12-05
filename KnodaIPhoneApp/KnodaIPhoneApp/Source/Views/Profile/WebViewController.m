//
//  TermsOfServiceViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebViewController.h"
#import "WebApi.h"

@interface WebViewController ()

@property (nonatomic, strong) IBOutlet UIWebView* webView;
@property (strong, nonatomic) NSString *url;

@end

@implementation WebViewController

- (id)initWithURL:(NSString *)url {
    self = [super initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]];
    self.url = url;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backButtonPressed:)];
    self.title = @"KNODA";
}


- (void)viewWillAppear:(BOOL)animated {
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:requestObj];
    
    [super viewWillAppear: animated];
}


- (IBAction) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
