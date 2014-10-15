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
#import "NavigationViewController.h"
#import "StartPredictingViewController.h"

#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in your iPhone's settings to continue."
#define ERROR_PERM_ACCESS @"Sorry, you can't sign in with Twitter without granting us access to the accounts on your device."
#define ERROR_OK @"OK"

@interface WelcomeViewController ()
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (weak, nonatomic) IBOutlet UIButton *knodaUserButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@end

@implementation WelcomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent:@"LANDING"];
    
    self.title = @"WELCOME";
    
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
    
    self.view.backgroundColor = [UIColor clearColor];
    

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRect frame = self.knodaUserButton.frame;
    frame.origin.x = self.twitterButton.frame.origin.x + self.twitterButton.frame.size.width - frame.size.width;
    self.knodaUserButton.frame = frame;
    [self showLoginSignup];
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    
//    [[UserManager sharedInstance] authenticateSavedUser:^(User *user, NSError *error) {
//        if (error)
//            [self showLoginSignup];
//        else
//            [appDelegate login];
//    }];

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
        
    [[UserManager sharedInstance] socialSignIn:request completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (!error) {
            NSDate *today = [NSDate date];
            NSDate *newDate = [today dateByAddingTimeInterval:-60];
            if (user.createdAt <= newDate) {
                [Flurry logEvent:@"SIGNUP_TWITTER"];
                StartPredictingViewController *vc = [[StartPredictingViewController alloc] initWithImage:nil];
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                [Flurry logEvent:@"LOGIN_TWITTER"];
                [[NSNotificationCenter defaultCenter] postNotificationName:UserLoggedInNotificationName object:nil];
            }
            NSString *inStr = [@(user.userId) stringValue];
            [Flurry setUserID:inStr];
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
        
        [[UserManager sharedInstance] socialSignIn:request completion:^(User *user, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (!error) {
                
                NSDate *today = [NSDate date];
                NSDate *newDate = [today dateByAddingTimeInterval:-60];
                if (user.createdAt <= newDate) {
                    [Flurry logEvent:@"SIGNUP_FACEBOOK"];
                    
                    StartPredictingViewController *vc = [[StartPredictingViewController alloc] initWithImage:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    [Flurry logEvent:@"LOGIN_FACEBOOK"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UserLoggedInNotificationName object:nil];
                }
                NSString *inStr = [@(user.userId) stringValue];
                [Flurry setUserID:inStr];
            }
            else {
                [[LoadingView sharedInstance] hide];
                [self showError:[error localizedDescription]];
            }
        }];
    }];
}

@end
