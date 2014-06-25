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
#import <Accounts/Accounts.h>
#import "TWAPIManager.h"    
#import "LoadingView.h"
#import "AppDelegate.h"
#import "UserManager.h"
#import "FacebookManager.h"
#import "WebViewController.h"
#import "TwitterManager.h"  

#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in your iPhone's settings to continue."
#define ERROR_PERM_ACCESS @"Sorry, you can't sign in with Twitter without granting us access to the accounts on your device."
#define ERROR_OK @"OK"

@interface WelcomeViewController ()
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;

@end

@implementation WelcomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent:@"LANDING"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:LoginResponseKey])
        self.termsLabel.hidden = YES;
    
    
    NSDictionary *allAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:10.0]};
    NSDictionary *underlined = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    NSMutableAttributedString *termsString = [[NSMutableAttributedString alloc] initWithString:@"By signing up, I agree to the "];
    
    [termsString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Terms of Service" attributes:underlined]];
    [termsString appendAttributedString:[[NSAttributedString alloc] initWithString:@" and "]];
    [termsString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Privacy Policy" attributes:underlined]];
    
    [termsString addAttributes:allAttributes range:NSMakeRange(0, termsString.length)];
    
    self.termsLabel.attributedText = termsString;
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    [[UserManager sharedInstance] authenticateSavedUser:^(User *user, NSError *error) {
        if (error)
            [self showLoginSignup];
        else
            [appDelegate login];
    }];

}
- (IBAction)termsPressed:(id)sender {
    WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.com/terms"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)privacyPolicyPressed:(id)sender {
    WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.com/privacy"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)showLoginSignup {
    [UIView animateWithDuration:0.5 animations:^{
        self.splashImage.alpha = 0;
    } completion:^(BOOL finished){}];
}

- (IBAction)login:(id)sender {
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
    [Flurry logEvent:@"LOGIN_EMAIL"];
}

- (IBAction)signup:(id)sender {
    SignUpViewController *vc = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
    [Flurry logEvent:@"SIGNUP_EMAIL"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)twitterSignIn:(SocialAccount *)request {
    [[LoadingView sharedInstance] show];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[UserManager sharedInstance] socialSignIn:request completion:^(User *user, NSError *error) {
        
        if (!error) {
            NSDate *today = [NSDate date];
            NSDate *newDate = [today dateByAddingTimeInterval:-60];
            if (user.createdAt <= newDate) {
                [Flurry logEvent:@"SIGNUP_TWITTER"];
                
            } else {
                [Flurry logEvent:@"LOGIN_TWITTER"];
            }
            NSString *inStr = [@(user.userId) stringValue];
            [Flurry setUserID:inStr];
            [appDelegate login];
        }
        else {
            [[LoadingView sharedInstance] hide];
            [self showError:[error localizedDescription]];
        }
    }];
}
- (void)showError:(NSString *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)twitter:(id)sender {
    [[TwitterManager sharedInstance] performReverseAuth:^(SocialAccount *request, NSError *error) {
        if (error) {
            return;
        }
        [self twitterSignIn:request];
    }];
}

- (IBAction)facebook:(id)sender {
    [[LoadingView sharedInstance] show];
    // If the session state is any of the two "open" states when the button is clicked
    [[FacebookManager sharedInstance] openSession:^(NSDictionary *data, NSError *error) {
        
        if (error) {
            [[LoadingView sharedInstance] hide];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        SocialAccount *request = [[SocialAccount alloc] init];
        request.providerName = @"facebook";
        request.providerId = data[@"id"];
        request.accessToken = [[FacebookManager sharedInstance] accessTokenForCurrentSession];
        
        NSLog(@"%@", [MTLJSONAdapter JSONDictionaryFromModel:request]);
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [[UserManager sharedInstance] socialSignIn:request completion:^(User *user, NSError *error) {
            if (!error) {
                NSDate *today = [NSDate date];
                NSDate *newDate = [today dateByAddingTimeInterval:-60];
                if (user.createdAt <= newDate) {
                    [Flurry logEvent:@"SIGNUP_FACEBOOK"];
                } else {
                    [Flurry logEvent:@"LOGIN_FACEBOOK"];
                }
                NSString *inStr = [@(user.userId) stringValue];
                [Flurry setUserID:inStr];
                [appDelegate login];
            }
            else {
                [[LoadingView sharedInstance] hide];
                [self showError:[error localizedDescription]];
            }
        }];
    }];
}

@end
