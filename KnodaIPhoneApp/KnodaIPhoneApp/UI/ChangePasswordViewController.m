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

@interface ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, readonly) AppDelegate* appDelegate;

@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet CustomizedTextField *retypeNewPasswordTextField;
@property (weak, nonatomic) IBOutlet CustomizedTextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet CustomizedTextField *usersNewPasswordTextField;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSInteger scrollContentHeight = self.scrollView.frame.size.height;
    scrollContentHeight = scrollContentHeight > 480 ? scrollContentHeight * 1.05 : scrollContentHeight * 1.23;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, scrollContentHeight);
    self.scrollView.scrollEnabled = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern"]];
}

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (IBAction)backButtonPress:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonPress:(id)sender {
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
    self.loadingView.hidden = NO;
    
    ChangePasswordRequest * changePasswordRequest = [[ChangePasswordRequest alloc]initWithCurrentPassword:self.currentPasswordTextField.text newPassword:self.usersNewPasswordTextField.text];
    [changePasswordRequest executeWithCompletionBlock:^{
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil];
        if (changePasswordRequest.errorCode == 0) {

            alertView.title = NSLocalizedString(@"Succes", @"");
            alertView.message = NSLocalizedString(@"Password has been changed succesfully", @"");
            
            LoginWebRequest *loginRequest = [[LoginWebRequest alloc] initWithUsername:self.appDelegate.user.name password:self.usersNewPasswordTextField.text];
            [loginRequest executeWithCompletionBlock:^{
                self.loadingView.hidden = YES;
                if(loginRequest.isSucceeded) {
                    [self.appDelegate.user updateWithObject:loginRequest.user];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    alertView.title = NSLocalizedString(@"Error", @"");
                    alertView.message = loginRequest.localizedErrorDescription;
                }
                [alertView show];
            }];
        }
        else {
            self.loadingView.hidden = YES;
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

    [self.scrollView scrollRectToVisible:self.scrollView.frame animated:YES];
    self.scrollView.scrollEnabled = NO;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    self.scrollView.scrollEnabled = YES;
    return YES;
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
