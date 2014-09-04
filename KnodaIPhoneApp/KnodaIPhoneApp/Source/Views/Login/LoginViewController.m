//
//  LoginViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/16/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "ForgotPasswordViewController.h"
#import "LoadingView.h"
#import "WebApi.h"
#import "UserManager.h"
#import "NavigationViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"WELCOME BACK";

}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear: animated];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)didTap {
    [self.view endEditing:YES];
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forgotPasswordPressed:(id)sender {
    ForgotPasswordViewController *vc = [[ForgotPasswordViewController alloc] initWithEmail:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL) checkTextFields {
    if (self.usernameTextField.text.length == 0) {
        
        [self showError: NSLocalizedString(@"Username should not be empty", @"")];
        
        [self.usernameTextField becomeFirstResponder];
        return NO;

    }
    else if (self.passwordTextField.text.length == 0) {
        
        [self showError: NSLocalizedString(@"Password should not be empty", @"")];
        
        [self.passwordTextField becomeFirstResponder];
        return NO;

    }

    return YES;
}


- (IBAction)loginButtonPressed:(id) sender {
    
    if (![self checkTextFields])
        return;
    
    [[LoadingView sharedInstance] show];
    [self.view endEditing:YES];
    
    
    LoginRequest *request = [[LoginRequest alloc] init];
    request.login = self.usernameTextField.text;
    request.password = self.passwordTextField.text;
        
    [[UserManager sharedInstance] login:request completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UserLoggedInNotificationName object:nil];
        NSString *inStr = [@(user.userId) stringValue];
        [Flurry setUserID:inStr];
         }
        else {
            if (error.code == HttpStatusForbidden)
                [self showError:NSLocalizedString(@"Invalid username or password", @"")];
            else if (error.code == HttpStatusGone) {
                [self showError:NSLocalizedString(@"This version of the app is no longer available. Please update and try again.", @"")];
            }
            else
                [self showError:@"An unknown error occurred. Please try again later"];
        }
    }];
}

#pragma mark UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField)
        [self.passwordTextField becomeFirstResponder];
    else if (textField == self.passwordTextField)
        [self loginButtonPressed: self];
    
    return NO;
}


#pragma mark - Error UI


- (void)showError:(NSString *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
