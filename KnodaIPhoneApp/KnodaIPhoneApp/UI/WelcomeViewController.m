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
        
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:YES];
    
    if ([UIScreen mainScreen].bounds.size.height > 480)
        self.test.image = [UIImage imageNamed:@"Default@2x-568h.png"];


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
    } completion:^(BOOL finished) {
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
