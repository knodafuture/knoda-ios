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

@property (nonatomic, strong) IBOutlet UIScrollView* pagingScroll;
@property (weak, nonatomic) IBOutlet UIImageView *splashView;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;

@end

@implementation WelcomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.buttonsContainer.alpha = 0.0;
    self.swipeArrow.alpha = 0.0;
    self.swipeLabel.alpha = 0.0;
    
    self.navigationController.navigationBar.translucent = NO;
    
    if ([UIScreen mainScreen].bounds.size.height > 480) {
        self.screen1.image = [UIImage imageNamed:@"Screen1@2x-568h.png"];
        self.screen2.image = [UIImage imageNamed:@"Screen2@2x-568h.png"];
        self.screen3.image = [UIImage imageNamed:@"Screen3@2x-568h.png"];
        self.screen4.image = [UIImage imageNamed:@"Screen4@2x-568h.png"];
        self.screen5.image = [UIImage imageNamed:@"Screen5@2x-568h.png"];
    } else {
        self.screen1.image = [UIImage imageNamed:@"Screen1"];
        self.screen2.image = [UIImage imageNamed:@"Screen2"];
        self.screen3.image = [UIImage imageNamed:@"Screen3"];
        self.screen4.image = [UIImage imageNamed:@"Screen4"];
        self.screen5.image = [UIImage imageNamed:@"Screen5"];
    }
    
    self.pagingScroll.contentSize = CGSizeMake(self.screen1.frame.size.width * 6, self.screen1.frame.size.height);


}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary* credentials = [appDelegate credentials];
    
    if (credentials != nil)
    {
        LoginWebRequest* request = [[LoginWebRequest alloc] initWithUsername: [credentials objectForKey: @"User"] password: [credentials objectForKey: @"Password"]];
        [request executeWithCompletionBlock: ^
         {
             if (request.errorCode != 0)
             {
                 [appDelegate removePassword];
                 [self showLoginSignup];
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
                          [self showLoginSignup];
                      }
                  }];
             }
         }];
    } else {
        [self showLoginSignup];
    }
}

- (void)showLoginSignup {
    [UIView animateWithDuration:0.5 animations:^{
        self.buttonsContainer.alpha = 1.0;
        self.swipeLabel.alpha = 1.0;
        self.swipeArrow.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

}

@end
