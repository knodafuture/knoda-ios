//
//  ViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "WebApi.h"
#import "UserManager.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *pagingScroll;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;

@end

@implementation WelcomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.buttonsContainer.alpha = 0.0;
    self.swipeArrow.alpha = 0.0;
    self.swipeLabel.alpha = 0.0;
    self.pagingScroll.scrollEnabled = NO;
    self.navigationController.navigationBar.translucent = NO;

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
        
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
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.pagingScroll.contentSize = CGSizeMake(self.screen1.frame.size.width * 6, self.screen1.frame.size.height);

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    LoginRequest *request = [[UserManager sharedInstance] loginRequestForSavedUser];
    
    if (!request) {
        [self showLoginSignup];
        return;
    }
    
    [[UserManager sharedInstance] login:request completion:^(User *user, NSError *error) {
        if (error)
            [self showLoginSignup];
        else
            [appDelegate login];
    }];

}

- (void)showLoginSignup {
    self.pagingScroll.scrollEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.buttonsContainer.alpha = 1.0;
        self.swipeLabel.alpha = 1.0;
        self.swipeArrow.alpha = 1.0;
    } completion:^(BOOL finished){}];
}

- (IBAction)login:(id)sender {
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)signup:(id)sender {
    SignUpViewController *vc = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
