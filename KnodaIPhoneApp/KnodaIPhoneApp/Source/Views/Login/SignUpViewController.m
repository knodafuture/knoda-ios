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

#ifndef TESTFLIGHT
#import <Tapjoy/Tapjoy.h>
#endif

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
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Sign Up" target:self action:@selector(signUpPressed) color:[UIColor whiteColor]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:tap];
    [self.navigationController setNavigationBarHidden:NO];
    //By signing up, I agree to the Terms of Service and Privacy Policy
    
    NSDictionary *allAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:10.0]};
    NSDictionary *underlined = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    
    NSMutableAttributedString *termsString = [[NSMutableAttributedString alloc] initWithString:@"By signing up, I agree to the "];
    
    [termsString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Terms of Service" attributes:underlined]];
    [termsString appendAttributedString:[[NSAttributedString alloc] initWithString:@" and "]];
    [termsString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Privacy Policy" attributes:underlined]];
    
    [termsString addAttributes:allAttributes range:NSMakeRange(0, termsString.length)];
    
    self.termsLabel.attributedText = termsString;

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

- (IBAction)termsPressed:(id)sender {
    WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.com/terms"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)privacyPolicyPressed:(id)sender {
    WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.com/privacy"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)signUpPressed {
    
    if (![self checkTextFields])
        return;
    
    [self.view endEditing:YES];
    
    
    SignupRequest *request = [[SignupRequest alloc] init];
    request.email = self.emailTextFiled.text;
    request.username = self.usernameTextField.text;
    request.password = self.passwordTextField.text;
    
    [[LoadingView sharedInstance] show];
    
    [[WebApi sharedInstance] sendSignUpWithRequest:request completion:^(LoginResponse *response, NSError *error) {
        [[LoadingView sharedInstance] hide];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstLaunchKey];
        if (!error) {
            [[self appDelegate] doLogin:(LoginRequest *)request withResponse:response];
#ifndef TESTFLIGHT
            [Tapjoy actionComplete:@"8e4c3953-3a2d-471b-8775-ce1aca4165f4"];
#endif
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

- (void)showError:(NSString *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}



@end
