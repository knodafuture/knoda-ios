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

@property (nonatomic, strong) IBOutlet UITextField* textField;

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
    self.title = @"PASSWORD RESET";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self action:@selector(sendButtonPressed:) color:[UIColor whiteColor]];
}


- (void) viewDidUnload
{
    self.textField = nil;
    
    [super viewDidUnload];
}


- (void) viewWillAppear: (BOOL) animated
{
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willShowKeyboardNotificationDidRecieve:) name: UIKeyboardWillShowNotification object: nil];
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willHideKeyboardNotificationDidRecieve:) name: UIKeyboardWillHideNotification object: nil];
    
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


//- (void) willShowKeyboardNotificationDidRecieve: (NSNotification*) notification
//{
//    if ([self.textField isFirstResponder])
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
//    if ([self.textField isFirstResponder])
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
    if (textField == self.textField)
    {
        [self sendButtonPressed: self];
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
