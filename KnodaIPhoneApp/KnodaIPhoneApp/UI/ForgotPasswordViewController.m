//
//  ForgotPasswordViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ForgotPasswordViewController.h"

#import "CustomizedTextField.h"
#import "ForgotPasswordWebRequest.h"
#import "LoadingView.h"

@interface ForgotPasswordViewController ()

@property (nonatomic, strong) IBOutlet CustomizedTextField* textField;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UIView* errorView;
@property (nonatomic, strong) IBOutlet UILabel* errorLabel;

@property (nonatomic, assign) BOOL errorShown;

@end



@implementation ForgotPasswordViewController
{
    NSString* email;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if (self.email != nil)
    {
        self.textField.text = self.email;
    }
}


- (void) viewDidUnload
{
    self.textField = nil;
    
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


#pragma mark - Properties


- (NSString*) email
{
    return email;
}


- (void) setEmail: (NSString*) newEmail
{
    email = newEmail;
    
    if (self.textField != nil)
    {
        self.textField.text = email;
    }
}


#pragma mark - Actions


- (IBAction) cancelButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}


- (IBAction) sendButtonPressed: (id) sender
{
    if (self.textField.text.length == 0)
    {
        [self showError: NSLocalizedString(@"Please enter your email", @"")];
    }
    else
    {
        [[LoadingView sharedInstance] show];
        
        ForgotPasswordWebRequest* forgotPasswordRequest = [[ForgotPasswordWebRequest alloc] initWithEmail: self.textField.text];
        [forgotPasswordRequest executeWithCompletionBlock: ^
         {
             [[LoadingView sharedInstance] hide];
             
             if (forgotPasswordRequest.errorCode == 0)
             {
                 UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"A link to reset your password was sent to your email", @"") delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
                 
                 [alert show];
                 
                 [self.navigationController popViewControllerAnimated: YES];
             }
             else if (forgotPasswordRequest.errorCode == 404)
             {
                 [self showError: NSLocalizedString(@"Email was not found", @"")];
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
    if ([self.textField isFirstResponder])
    {
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown: YES withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
    }
}

- (void) willHideKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    if ([self.textField isFirstResponder])
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
    if (textField == self.textField)
    {
        [self sendButtonPressed: self];
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
