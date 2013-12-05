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

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];

}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear: animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Sign In" target:self action:@selector(loginButtonPressed:) color:[UIColor whiteColor]];
    
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
        return NO;
        
        [self showError: NSLocalizedString(@"Username should not be empty", @"")];
        
        [self.usernameTextField becomeFirstResponder];
    }
    else if (self.passwordTextField.text.length == 0) {
        return NO;
        
        [self showError: NSLocalizedString(@"Password should not be empty", @"")];
        
        [self.passwordTextField becomeFirstResponder];
    }

    return YES;
}


- (void)loginButtonPressed:(id) sender {
    
    if (![self checkTextFields])
        return;
    
    [[LoadingView sharedInstance] show];
    [self.view endEditing:YES];
    
    
    LoginRequest *request = [[LoginRequest alloc] init];
    request.username = self.usernameTextField.text;
    request.password = self.passwordTextField.text;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[WebApi sharedInstance] authenticateUser:request completion:^(LoginResponse *response, NSError *error) {
        if (!error)
            [appDelegate doLogin:request withResponse:response];
        else {
            [[LoadingView sharedInstance] hide];
            if (error.code == HttpStatusForbidden)
                [self showError:NSLocalizedString(@"Invalid username or password", @"")];
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
