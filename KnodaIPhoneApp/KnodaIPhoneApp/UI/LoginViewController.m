//
//  LoginViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/16/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "LoginWebRequest.h"
#import "ForgotPasswordViewController.h"
#import "ProfileWebRequest.h"
#import "LoadingView.h"

static NSString* const kApplicationSegue = @"ApplicationNavigationSegue";

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, readonly) AppDelegate* appDelegate;

@property (nonatomic, strong) IBOutlet UITextField* usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField* passwordTextField;

@end

@implementation LoginViewController

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willShowKeyboardNotificationDidRecieve:) name: UIKeyboardWillShowNotification object: nil];
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willHideKeyboardNotificationDidRecieve:) name: UIKeyboardWillHideNotification object: nil];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Sign In" target:self action:@selector(loginButtonPressed:) color:[UIColor whiteColor]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:tap];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super viewWillDisappear: animated];
}
- (void)didTap {
    [self.view endEditing:YES];
}
- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if ([segue.identifier isEqualToString: @"ForgotPasswordSegue"] && [self.usernameTextField.text rangeOfString: @"@"].location != NSNotFound)
    {
        ((ForgotPasswordViewController*)segue.destinationViewController).email = self.usernameTextField.text;
    }
}


- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}


- (BOOL) checkTextFields
{    
    if (self.usernameTextField.text.length == 0)
    {
        return NO;
        
        [self showError: NSLocalizedString(@"Username should not be empty", @"")];
        
        [self.usernameTextField becomeFirstResponder];
    }
    else if (self.passwordTextField.text.length == 0)
    {
        return NO;
        
        [self showError: NSLocalizedString(@"Password should not be empty", @"")];
        
        [self.passwordTextField becomeFirstResponder];
    }

    return YES;
}


- (IBAction) loginButtonPressed: (id) sender
{
    if ([self checkTextFields])
    {
        [[LoadingView sharedInstance] show];
        
        if ([self.usernameTextField isFirstResponder])
        {
            [self.usernameTextField resignFirstResponder];
        }
        
        if ([self.passwordTextField isFirstResponder])
        {
            [self.passwordTextField resignFirstResponder];
        }
                
        LoginWebRequest* loginRequest = [[LoginWebRequest alloc] initWithUsername: self.usernameTextField.text password: self.passwordTextField.text];
        [loginRequest executeWithCompletionBlock: ^
         {             
             if (loginRequest.errorCode == 0)
             {
                 self.appDelegate.user = loginRequest.user;
                 
                 ProfileWebRequest *profileRequest = [ProfileWebRequest new];
                 [profileRequest executeWithCompletionBlock: ^
                 {
                     [[LoadingView sharedInstance] hide];
                     
                     if (profileRequest.isSucceeded)
                     {
                         [self.appDelegate.user updateWithObject:profileRequest.user];
                         [self.appDelegate savePassword: self.passwordTextField.text];
                         
                         [self.appDelegate sendToken];
                         
                         [self performSegueWithIdentifier: kApplicationSegue  sender: self];
                     }
                     else
                     {
                         [self showError:profileRequest.localizedErrorDescription];
                     }
                 }];
             }
             else {
                 [[LoadingView sharedInstance] hide];
                 if (loginRequest.errorCode == 403)
                 {
                     [self showError: NSLocalizedString(@"Invalid username or password", @"")];
                 }
                 else
                 {
                     [self showError: loginRequest.localizedErrorDescription];
                 }
             }
         }];
    }
}


#pragma mark - Handle keyboard show/hide events


//- (void) willShowKeyboardNotificationDidRecieve: (NSNotification*) notification
//{
//    if ([self.usernameTextField isFirstResponder] || [self.passwordTextField isFirstResponder])
//    {
//        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
//        
//        [self moveUpOrDown: YES withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
//    }
//}
//
//- (void) willHideKeyboardNotificationDidRecieve: (NSNotification*) notification
//{
//    if ([self.usernameTextField isFirstResponder] || [self.passwordTextField isFirstResponder])
//    {
//        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
//        
//        [self moveUpOrDown:NO withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
//    }
//}


#pragma mark UITextFieldDelegate


- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    if (textField == self.usernameTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField)
    {
        [self loginButtonPressed: self];
    }
    
    return NO;
}


#pragma mark - Error UI


- (void) showError: (NSString*) error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
