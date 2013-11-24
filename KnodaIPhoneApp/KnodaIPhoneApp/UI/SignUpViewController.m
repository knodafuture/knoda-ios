//
//  SignUpViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/18/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SignUpViewController.h"

#import "AppDelegate.h"

#import "SignUpRequest.h"
#import "PredictionsWebRequest.h"
#import "ProfileWebRequest.h"
#import "LoadingView.h"


static const NSInteger kMaxUsernameLength = 15;
static const NSInteger kMinPasswordLength = 6;
static const NSInteger kMaxPasswordLength = 20;

static NSString* const kApplicationSegue   = @"ApplicationNavigationSegue";

@interface SignUpViewController ()

@property (nonatomic, readonly) AppDelegate* appDelegate;

@property (nonatomic, strong) IBOutlet UITextField* usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField* passwordTextField;
@property (nonatomic, strong) IBOutlet UITextField* emailTextFiled;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainerView;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Sign Up" target:self action:@selector(signUpButtonPressed:) color:[UIColor whiteColor]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:tap];
    [self.navigationController setNavigationBarHidden:NO];

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
- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (void)didTap {
    [self.view endEditing:YES];
}

- (BOOL) checkTextFields
{    
    if (self.emailTextFiled.text.length == 0)
    {
        
        [self showError: NSLocalizedString(@"Email should not be empty", @"")];
        
        [self.emailTextFiled becomeFirstResponder];
        
        return NO;

    }
    else if (self.usernameTextField.text.length == 0)
    {
        
        [self showError: NSLocalizedString(@"Username should not be empty", @"")];
        
        [self.usernameTextField becomeFirstResponder];
        return NO;

    }
    else if (self.passwordTextField.text.length < kMinPasswordLength)
    {
        
        [self showError: NSLocalizedString(@"Password should be between 6 and 20 chars lenght", @"")];
        
        [self.passwordTextField becomeFirstResponder];
        
        return NO;

    }
    
    return YES;
    
}


#pragma mark IBAction


- (IBAction) signUpButtonPressed: (id) sender
{
    if ([self checkTextFields])
    {
        [[LoadingView sharedInstance] show];
        
        if ([self.emailTextFiled isFirstResponder])
        {
            [self.emailTextFiled resignFirstResponder];
        }
        
        if ([self.usernameTextField isFirstResponder])
        {
            [self.usernameTextField resignFirstResponder];
        }
        
        if ([self.passwordTextField isFirstResponder])
        {
            [self.passwordTextField resignFirstResponder];
        }
        
        SignUpRequest* signUpRequest = [[SignUpRequest alloc] initWithUsername: self.usernameTextField.text email: self.emailTextFiled.text password: self.passwordTextField.text];
        [signUpRequest executeWithCompletionBlock: ^
         {
             if (signUpRequest.isSucceeded)
             {
                 self.appDelegate.user = signUpRequest.user;
                 
                 ProfileWebRequest *profileRequest = [ProfileWebRequest new];
                 [profileRequest executeWithCompletionBlock: ^
                  {
                      [[LoadingView sharedInstance] hide];
                      
                      if (profileRequest.isSucceeded)
                      {
                          [self.appDelegate sendToken];
                          
                          [self.appDelegate.user updateWithObject: profileRequest.user];
                          [self.appDelegate savePassword: self.passwordTextField.text];
                          
                          self.appDelegate.user.justSignedUp = YES;
                          
                          [self performSegueWithIdentifier: kApplicationSegue  sender: self];
                      }
                      else
                      {
                          [self showError:profileRequest.localizedErrorDescription];
                      }
                  }];
             }
             else
             {
                 [[LoadingView sharedInstance] hide];
                 if (signUpRequest.errorCode == 403)
                 {
                     [self showError: NSLocalizedString(@"Invalid username or password", @"")];
                 }
                 else
                 {
                     [self showError: signUpRequest.localizedErrorDescription];
                 }
             }
         }];
    }
}


#pragma mark - Handle keyboard show/hide events


- (void) willShowKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = self.containerView.frame;
    frame.origin.y = 0 - self.textFieldContainerView.frame.origin.y + 10.0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.containerView.frame = frame;
    }];
}

- (void) willHideKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = self.containerView.frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.containerView.frame = frame;
    }];
}


- (BOOL) checkUsernameSubstring: (NSString*) usernameSubstring
{
    BOOL result = YES;
    
    for (int i = 0; i < usernameSubstring.length; i++)
    {
        char ch = [usernameSubstring characterAtIndex: i];
        
        result = ((ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || ch == '_');
    }
    
    return result;
}


#pragma mark UITextFieldDelegate


- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    if (textField == self.emailTextFiled)
    {
        [self.usernameTextField becomeFirstResponder];
    }
    else if (textField == self.usernameTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField)
    {
        [self signUpButtonPressed: self];
    }
    
    return NO;
}

- (BOOL) textField: (UITextField*) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString*) string
{
    BOOL result = YES;
    
    if (textField == self.usernameTextField)
    {
        if ([self checkUsernameSubstring: string])
        {
            NSString* resultString = [textField.text stringByReplacingCharactersInRange: range withString: string];
            
            if (resultString.length > kMaxUsernameLength)
            {
                result = NO;
                
                resultString = [resultString substringToIndex: kMaxUsernameLength - 1];
                textField.text = resultString;
            }
        }
        else
        {
            result = NO;
        }
    }
    else if (textField == self.passwordTextField)
    {
        NSString* resultString = [textField.text stringByReplacingCharactersInRange: range withString: string];
        
        if (resultString.length > kMaxPasswordLength)
        {
            result = NO;
            
            resultString = [resultString substringToIndex: kMaxPasswordLength - 1];
            textField.text = resultString;
        }
    }
    
    return result;
}


#pragma mark - Error UI


- (void) showError: (NSString*) error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}



@end
