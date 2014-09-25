//
//  SignUpViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/18/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "WebApi.h"
#import "WebViewController.h"
#import "UserManager.h"
#import "WalkthroughController.h"
#import "ContestWalkthroughController.h"
#import "LoginViewController.h"
#import "TwitterManager.h"
#import "FacebookManager.h"
#import "NavigationViewController.h"
#import "NewSelectPictureViewController.h"
#import "StartPredictingViewController.h"

static const NSInteger kMaxUsernameLength = 15;
static const NSInteger kMinPasswordLength = 6;
static const NSInteger kMaxPasswordLength = 20;

@interface SignUpViewController ()

@property (readonly, nonatomic) AppDelegate* appDelegate;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextFiled;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainerView;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed)];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:tap];
    
    self.title = @"SIGN UP";

}

- (void)viewWillAppear:(BOOL) animated {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willShowKeyboardNotificationDidRecieve:) name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willHideKeyboardNotificationDidRecieve:) name: UIKeyboardWillHideNotification object: nil];
    [super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super viewWillDisappear: animated];
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (AppDelegate*)appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (void)didTap {
    [self.view endEditing:YES];
}

- (BOOL)checkTextFields {
    if (self.emailTextFiled.text.length == 0) {
        [self showError: NSLocalizedString(@"Email should not be empty", @"")];
        [self.emailTextFiled becomeFirstResponder];
        return NO;
    } else if (self.usernameTextField.text.length == 0) {
        [self showError: NSLocalizedString(@"Username should not be empty", @"")];
        [self.usernameTextField becomeFirstResponder];
        return NO;
    } else if (self.passwordTextField.text.length < kMinPasswordLength) {
        [self showError: NSLocalizedString(@"Password should be between 6 and 20 chars length", @"")];
        [self.passwordTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (IBAction)twitterSignUp:(id)sender {
    [[TwitterManager sharedInstance] performReverseAuth:^(SocialAccount *request, NSError *error) {
        if (error) {
            return;
        }
        [self twitterSignIn:request];
    }];
}

- (IBAction)facebookSignUp:(id)sender {
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
                    [[NSNotificationCenter defaultCenter] postNotificationName:UserLoggedInNotificationName object:nil];

                    [Flurry logEvent:@"LOGIN_FACEBOOK"];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:UserLoggedInNotificationName object:nil];
                [Flurry logEvent:@"LOGIN_TWITTER"];
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

- (IBAction)loginPressed:(id)sender {
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)signUpPressed {
    if (![self checkTextFields])
        return;
    
    [self.view endEditing:YES];
    
    
    SignupRequest *request = [[SignupRequest alloc] init];
    request.email = self.emailTextFiled.text;
    request.username = self.usernameTextField.text;
    request.password = self.passwordTextField.text;
    
    [[LoadingView sharedInstance] show];
    
    [[UserManager sharedInstance] signup:request completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (!error) {
            NSString *inStr = [@(user.userId) stringValue];
            [Flurry setUserID:inStr];

            
            NewSelectPictureViewController *vc = [[NewSelectPictureViewController alloc] initWithNibName:@"NewSelectPictureViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        else
            [self showError:error.localizedDescription];
            
    }];
}

- (void)willShowKeyboardNotificationDidRecieve:(NSNotification *)notification {
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = self.containerView.frame;
    frame.origin.y = 0 - self.textFieldContainerView.frame.origin.y + 10.0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.containerView.frame = frame;
    }];
}

- (void)willHideKeyboardNotificationDidRecieve:(NSNotification *)notification {
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = self.containerView.frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.containerView.frame = frame;
    }];
}


- (BOOL)checkUsernameSubstring:(NSString *)usernameSubstring {
    BOOL result = YES;
    
    for (int i = 0; i < usernameSubstring.length; i++) {
        char ch = [usernameSubstring characterAtIndex: i];
        result = ((ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || ch == '_');
    }
    
    return result;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextFiled)
        [self.usernameTextField becomeFirstResponder];
    else if (textField == self.usernameTextField)
        [self.passwordTextField becomeFirstResponder];
    else if (textField == self.passwordTextField)
        [self signUpPressed];
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = YES;
    
    if (textField == self.usernameTextField) {
        if ([self checkUsernameSubstring: string]) {
            NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            if (resultString.length > kMaxUsernameLength) {
                result = NO;
                resultString = [resultString substringToIndex: kMaxUsernameLength - 1];
                textField.text = resultString;
            }
        } else
            result = NO;
    } else if (textField == self.passwordTextField) {
        NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (resultString.length > kMaxPasswordLength) {
            result = NO;
            resultString = [resultString substringToIndex: kMaxPasswordLength - 1];
            textField.text = resultString;
        }
    }
    
    return result;
}

@end
