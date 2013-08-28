//
//  ViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"

#import "LoginWebRequest.h"
#import "ProfileWebRequest.h"

@interface WelcomeViewController ()

@property (nonatomic, strong) IBOutlet UILabel* promotionLabel;
@property (nonatomic, strong) IBOutlet UIScrollView* pagingScroll;
@property (nonatomic, strong) IBOutlet UIView* contentView;

@property (nonatomic, strong) IBOutlet UIView* loadingView;

@end

@implementation WelcomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.promotionLabel.font = [UIFont fontWithName: @"Krona One" size: 13];
    self.pagingScroll.contentSize = self.contentView.frame.size;
    
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary* credentials = [appDelegate credentials];
    
    if (credentials != nil)
    {
        self.loadingView.hidden = NO;
        
        LoginWebRequest* request = [[LoginWebRequest alloc] initWithUsername: [credentials objectForKey: @"User"] password: [credentials objectForKey: @"Password"]];
        [request executeWithCompletionBlock: ^
        {
            if (request.errorCode != 0)
            {
                [appDelegate removePassword];
                [self performSegueWithIdentifier: @"LoginSegue" sender: self];
            }
            else
            {
                appDelegate.user = request.user;
                
                ProfileWebRequest *profileRequest = [ProfileWebRequest new];
                [profileRequest executeWithCompletionBlock: ^
                 {
                     if (profileRequest.isSucceeded)
                     {
                         [appDelegate sendToken];
                         
                         [appDelegate.user updateWithObject: profileRequest.user];
                         [self performSegueWithIdentifier: @"ApplicationNavigationSegue" sender: self];
                     }
                     else
                     {
                         [self performSegueWithIdentifier: @"LoginSegue" sender: self];
                     }
                 }];
            }
        }];
    }
}


- (void) viewDidUnload
{
    self.promotionLabel = nil;
    self.pagingScroll = nil;
    self.contentView = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
