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
@property (nonatomic, strong) IBOutlet UIView* activityView;
@property (nonatomic, strong) IBOutlet UIView* errorView;
@property (nonatomic, strong) IBOutlet UILabel* errorLabel;

@property (nonatomic, assign) BOOL errorShown;
@property (nonatomic, assign) BOOL keyboardShown;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidUnload
{
    self.usernameTextField = nil;
    self.passwordTextField = nil;
    self.emailTextFiled = nil;
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
    
    if (self.emailTextFiled.text.length == 0)
    {
        result = NO;
        
        [self showError: NSLocalizedString(@"Email should not be empty", @"")];
        
        [self.emailTextFiled becomeFirstResponder];
    }
    else if (self.usernameTextField.text.length == 0)
    {
        result = NO;
                
        [self showError: NSLocalizedString(@"Username should not be empty", @"")];
        
        [self.usernameTextField becomeFirstResponder];
    }
    else if (self.passwordTextField.text.length < kMinPasswordLength)
    {
        
        result = NO;
                
        [self showError: NSLocalizedString(@"Password should be between 6 and 20 chars lenght", @"")];
        
        [self.passwordTextField becomeFirstResponder];
    }
    
    return result;
}


#pragma mark IBAction


- (IBAction) signUpButtonPressed: (id) sender
{
    if ([self checkTextFields])
    {
        self.activityView.hidden = NO;
        
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
        
        [self hideError];
        
        SignUpRequest* signUpRequest = [[SignUpRequest alloc] initWithUsername: self.usernameTextField.text email: self.emailTextFiled.text password: self.passwordTextField.text];
        [signUpRequest executeWithCompletionBlock: ^
         {
             self.activityView.hidden = YES;
             
             if (signUpRequest.errorCode == 0)
             {
                 self.appDelegate.user = signUpRequest.user;
                 
                 ProfileWebRequest *profileRequest = [ProfileWebRequest new];
                 [profileRequest executeWithCompletionBlock: ^
                  {
                      self.activityView.hidden = YES;
                      
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
             else if (signUpRequest.errorCode == 403)
             {
                 [self showError: NSLocalizedString(@"Invalid username or password", @"")];
             }
             else
             {
                 [self showError: signUpRequest.localizedErrorDescription];
             }
         }];
    }
}


#pragma mark - Handle keyboard show/hide events


- (void) willShowKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    if ([self.emailTextFiled isFirstResponder] || [self.usernameTextField isFirstResponder] || [self.passwordTextField isFirstResponder])
    {
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown: YES withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
        
        self.keyboardShown = YES;
    }
}

- (void) willHideKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    if ([self.emailTextFiled isFirstResponder] || [self.usernameTextField isFirstResponder] || [self.passwordTextField isFirstResponder])
    {
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown:NO withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
        
        self.keyboardShown = NO;
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
            if (self.errorShown) {
                newY += self.errorLabel.frame.size.height * 2;
            }
            
            newContainerFrame.origin.y = newY;
        }
    }
    else
    {
        newContainerFrame.origin.y = self.errorShown ? self.errorLabel.frame.size.height : 0;
    }
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:(animationCurve << 16) animations:^
     {
         self.containerView.frame = newContainerFrame;
     } completion: NULL];
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
    self.errorLabel.text = error;
    
    if (!self.errorShown)
    {
        self.errorShown = YES;
        
        CGRect newContainerFrame = self.containerView.frame;
        
        CGRect newErrorFrame = self.errorView.frame;
        newErrorFrame.origin.y += newErrorFrame.size.height;
        
        if ((newErrorFrame.origin.y == newContainerFrame.origin.y)&&!self.keyboardShown) {
            newContainerFrame.origin.y += self.errorLabel.frame.size.height;
        }
        else {
            newContainerFrame.origin.y += self.errorLabel.frame.size.height * 2;
        }
      
        [UIView animateWithDuration: 0.2 animations: ^
         {
             self.errorView.frame = newErrorFrame;
             
             self.containerView.frame = newContainerFrame;
         }];
    }
}


- (void) hideError
{
    if (self.errorShown)
    {
        self.errorLabel.text = nil;
        self.errorShown = NO;
        
        CGRect newContainerFrame = self.containerView.frame;
        
        if ((newContainerFrame.origin.y - self.errorLabel.frame.size.height * 2) <= 0) {
            newContainerFrame.origin.y -= self.errorLabel.frame.size.height * 2;
        }
        
        CGRect newErrorFrame = self.errorView.frame;
        newErrorFrame.origin.y -= newErrorFrame.size.height;
        
        [UIView animateWithDuration: 0.2 animations: ^
         {
             self.errorView.frame = newErrorFrame;
             
             self.containerView.frame = newContainerFrame;
         }];
    }
}

@end
