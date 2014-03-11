//
//  ChangePasswordViewController.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/21/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "WebApi.h"

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

    PasswordChangeRequest *request = [[PasswordChangeRequest alloc] init];
    request.password = self.usersNewPasswordTextField.text;
    request.currentPassword = self.currentPasswordTextField.text;

    [[WebApi sharedInstance] changePassword:request completion:^(User *user, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil];

        if (error) {
            [[LoadingView sharedInstance] hide];
            alertView.title = NSLocalizedString(@"Error", @"");
            alertView.message = NSLocalizedString(@"Old password is incorrect", @"");
            [alertView show];
            return;
        }
        
        alertView.title = NSLocalizedString(@"Succes", @"");
        alertView.message = NSLocalizedString(@"Password has been changed succesfully", @"");

        LoginRequest *request = [[LoginRequest alloc] init];
        request.login = self.appDelegate.currentUser.name;
        request.password = self.usersNewPasswordTextField.text;
        
        [[WebApi sharedInstance] authenticateUser:request completion:^(LoginResponse *response, NSError *error) {
            
            [[LoadingView sharedInstance] hide];
            
            if (error) {
                alertView.title = NSLocalizedString(@"Error", @"");
                alertView.message = error.localizedDescription;
                
                [self.appDelegate logout];
                return;
            }
            
            [self.appDelegate reauthorize:request withResponse:response];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

#pragma mark - passwords chechs 

- (BOOL)passwordsFilledInCorrect {
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
