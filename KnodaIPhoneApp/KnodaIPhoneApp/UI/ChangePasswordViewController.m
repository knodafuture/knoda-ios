//
//  ChangePasswordViewController.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/21/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ChangePasswordRequest.h"
#import "LoginWebRequest.h"
#import "AppDelegate.h"
#import "CustomizedTextField.h"
#import "ProfileWebRequest.h"
#import "LoadingView.h"

@interface ChangePasswordViewController ()

@property (nonatomic, readonly) AppDelegate* appDelegate;

@property (weak, nonatomic) IBOutlet UITextField *retypeNewPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usersNewPasswordTextField;


@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"PASSWORD";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backButtonPress:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self action:@selector(changeButtonPressed:) color:[UIColor whiteColor]];
}

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
    
}

- (IBAction)backButtonPress:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeButtonPressed:(id)sender {
    [self changePassword];
}

- (void) changePassword {

    if (![self passwordsFilledInCorrect]) {
        return;
    }
    [self hideKeyboard];
    [[LoadingView sharedInstance] show];
    
    ChangePasswordRequest * changePasswordRequest = [[ChangePasswordRequest alloc] initWithCurrentPassword:self.currentPasswordTextField.text newPassword:self.usersNewPasswordTextField.text];
    [changePasswordRequest executeWithCompletionBlock:^{
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil];
        if (changePasswordRequest.isSucceeded) {

            alertView.title = NSLocalizedString(@"Succes", @"");
            alertView.message = NSLocalizedString(@"Password has been changed succesfully", @"");
            
            LoginWebRequest *loginRequest = [[LoginWebRequest alloc] initWithUsername:self.appDelegate.user.name password:self.usersNewPasswordTextField.text];
            [loginRequest executeWithCompletionBlock:^{
                [[LoadingView sharedInstance] hide];
                if(loginRequest.isSucceeded)
                {
                    self.appDelegate.user = loginRequest.user;
                    
                    [self.appDelegate sendToken];
                    
                    ProfileWebRequest *profileRequest = [ProfileWebRequest new];
                    [profileRequest executeWithCompletionBlock: ^
                     {
                         if (profileRequest.isSucceeded)
                         {
                             [self.appDelegate.user updateWithObject:profileRequest.user];
                             [self.appDelegate savePassword: self.usersNewPasswordTextField.text];
                             
                             [self.navigationController popViewControllerAnimated:YES];
                         }
                         else
                         {
                             alertView.title = NSLocalizedString(@"Error", @"");
                             alertView.message = profileRequest.localizedErrorDescription;
                         }
                     }];
                }
                else {
                    alertView.title = NSLocalizedString(@"Error", @"");
                    alertView.message = loginRequest.localizedErrorDescription;
                    
                    [self.appDelegate logout];
                }
                [alertView show];
            }];
        }
        else {
            [[LoadingView sharedInstance] hide];
            alertView.title = NSLocalizedString(@"Error", @"");
            alertView.message = NSLocalizedString(@"Old password is incorrect", @"");
            [alertView show];
        }
    }];
}

#pragma mark - passwords chechs 

- (BOOL) passwordsFilledInCorrect {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil];
    if (([self.currentPasswordTextField.text length] > 5)&&([self.usersNewPasswordTextField.text length] > 5)&&([self.retypeNewPasswordTextField.text length] > 5)) {
        if ([self.usersNewPasswordTextField.text isEqualToString:self.retypeNewPasswordTextField.text]) {
            return YES;
        }
        else {
            alertView.message =  NSLocalizedString(@"Passwords do not match", @"");
            [alertView show];
            return NO;
        }
    }
    else {
        alertView.message =  NSLocalizedString(@"Minimum password length is 6 characters", @"");
        [alertView show];
        return NO;
    }
}

#pragma mark - TextField delegate

- (void) hideKeyboard {
    [self.currentPasswordTextField resignFirstResponder];
    [self.self.usersNewPasswordTextField resignFirstResponder];
    [self.retypeNewPasswordTextField resignFirstResponder];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if (textField == self.currentPasswordTextField) {
        [self.usersNewPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.usersNewPasswordTextField) {
        [self.retypeNewPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.retypeNewPasswordTextField) {
        [self changePassword];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text length] > 20) {
        textField.text = [textField.text substringToIndex:19];
        return NO;
    }
    return YES;
}

@end
