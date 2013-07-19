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
#import "PredictionsWebRequest.h"

@interface LoginViewController ()

@property (nonatomic, readonly) AppDelegate* appDelegate;

@property (nonatomic, strong) IBOutlet UITextField* usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField* passwordTextField;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UIView* activityView;
@property (nonatomic, strong) IBOutlet UIView* errorView;
@property (nonatomic, strong) IBOutlet UILabel* errorLabel;

@property (nonatomic, assign) BOOL errorShown;

@end

@implementation LoginViewController


- (void) viewDidUnload
{
    self.usernameTextField = nil;
    self.passwordTextField = nil;
    self.containerView = nil;
    self.activityView = nil;
    self.errorView = nil;
    self.errorLabel = nil;
    
    [super viewDidUnload];
}


- (void) viewWillAppear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willShowKeyboardNotificationDidRecieve:) name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willHideKeyboardNotificationDidRecieve:) name: UIKeyboardWillHideNotification object: nil];
    
    [super viewWillAppear: animated];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super viewWillDisappear: animated];
}


- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}


- (BOOL) checkTextFields
{
    BOOL result = YES;
    
    if (self.usernameTextField.text.length == 0)
    {
        result = NO;
        
        [self showError: NSLocalizedString(@"Username should not be empty", @"")];
        
        [self.usernameTextField becomeFirstResponder];
    }
    else if (self.passwordTextField.text.length == 0)
    {
        result = NO;
        
        [self showError: NSLocalizedString(@"Password should not be empty", @"")];
        
        [self.passwordTextField becomeFirstResponder];
    }

    return result;
}


- (IBAction) loginButtonPressed: (id) sender
{
    if ([self checkTextFields])
    {
        self.activityView.hidden = NO;
        
        if ([self.usernameTextField isFirstResponder])
        {
            [self.usernameTextField resignFirstResponder];
        }
        
        if ([self.passwordTextField isFirstResponder])
        {
            [self.passwordTextField resignFirstResponder];
        }
        
        [self hideError];
        
        LoginWebRequest* loginRequest = [[LoginWebRequest alloc] initWithUsername: self.usernameTextField.text password: self.passwordTextField.text];
        [loginRequest executeWithCompletionBlock: ^
         {
             self.activityView.hidden = YES;
             
             if (loginRequest.errorCode == 0)
             {
                 self.appDelegate.user = loginRequest.user;
                 
                 PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] init];
                 [predictionsRequest executeWithCompletionBlock: ^{}];
             }
             else if (loginRequest.errorCode == 403)
             {
                 [self showError: NSLocalizedString(@"Invalid username or password", @"")];
             }
             else
             {
                 [self showError: NSLocalizedString(@"Unknown error. Please try later.", @"")];
             }
         }];
    }
}


#pragma mark - Handle keyboard show/hide events


- (void) willShowKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    if ([self.usernameTextField isFirstResponder] || [self.passwordTextField isFirstResponder])
    {
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown: YES withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
    }
}

- (void) willHideKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    if ([self.usernameTextField isFirstResponder] || [self.passwordTextField isFirstResponder])
    {
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown:NO withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
    }
}


- (void) moveUpOrDown: (BOOL) up
withAnimationDuration: (NSTimeInterval)animationDuration
       animationCurve: (UIViewAnimationCurve)animationCurve
        keyboardFrame: (CGRect)keyboardFrame
{
    CGRect newContainerFrame = self.containerView.frame;
    
    if (up)
    {
        CGFloat newY = self.containerView.frame.origin.y - (CGRectGetMaxY(newContainerFrame) - CGRectGetMinY([self.containerView.superview convertRect: keyboardFrame fromView: self.view.window]));
        
        if (newY < newContainerFrame.origin.y)
        {
            newContainerFrame.origin.y = newY;
        }
    }
    else
    {
        newContainerFrame.origin.y = 0;
    }
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:(animationCurve << 16) animations:^
    {
        self.containerView.frame = newContainerFrame;
    } completion: NULL];
}


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
    self.errorLabel.text = error;
    
    if (!self.errorShown)
    {
        self.errorShown = YES;
        
        [UIView animateWithDuration: 0.2 animations: ^
         {
             CGRect newErrorFrame = self.errorView.frame;
             newErrorFrame.origin.y += newErrorFrame.size.height;
             
             self.errorView.frame = newErrorFrame;
         }];
    }
}


- (void) hideError
{
    if (self.errorShown)
    {
        self.errorLabel.text = nil;
        self.errorShown = NO;
        
        [UIView animateWithDuration: 0.2 animations: ^
         {
             CGRect newErrorFrame = self.errorView.frame;
             newErrorFrame.origin.y -= newErrorFrame.size.height;
             
             self.errorView.frame = newErrorFrame;
         }];
    }
}


@end
