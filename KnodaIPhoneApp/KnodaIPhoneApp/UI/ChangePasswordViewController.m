//
//  ChangePasswordViewController.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/21/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ChangePasswordRequest.h"
#import "PasswordCell.h"
#import "LoginWebRequest.h"
#import "AppDelegate.h"

static NSString * const kOldPasswordCellIdentifier = @"OldPasswordCell";
static NSString * const kNewPasswordCellIdentifier = @"NewPasswordCell";
static NSString * const kRetypeNewPasswordCellIdentifier = @"NewPasswordRetypeCell";

static NSInteger const kCurrentPasswordTextFieldTag = 101;
static NSInteger const kNewPasswordTextFieldTag = 102;
static NSInteger const kRetypeNewPasswordTextFieldTag = 103;

static NSInteger const kKeyboardHeight = 216;

@interface ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet UITableView *passwordsTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSString *usersNewPassword;
@property (nonatomic, strong) NSString *currentPassword;
@property (nonatomic, strong) NSString *retypeNewPassword;

@property (nonatomic, readonly) AppDelegate* appDelegate;

@property (weak, nonatomic) IBOutlet UIView *loadingView;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordsTableView.backgroundView = nil;
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
    
    [self setUpPasswordsValues];
    
    if (![self passwordsFilledInCorrect]) {
        return;
    }
    
    self.loadingView.hidden = NO;
    
    ChangePasswordRequest * changePasswordRequest = [[ChangePasswordRequest alloc]initWithCurrentPassword:self.currentPassword newPassword:self.usersNewPassword];
    [changePasswordRequest executeWithCompletionBlock:^{
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        if (changePasswordRequest.errorCode == 0) {

            alertView.title = NSLocalizedString(@"Succes", @"");
            alertView.message = NSLocalizedString(@"Password has been changed succesfully", @"");
            
            LoginWebRequest *loginRequest = [[LoginWebRequest alloc] initWithUsername:self.appDelegate.user.name password:self.usersNewPassword];
            [loginRequest executeWithCompletionBlock:^{
                self.loadingView.hidden = YES;
                if(loginRequest.isSucceeded) {
                    [self eraseTextFieldsText];
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
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    if (([self.currentPassword length] > 5)&&([self.usersNewPassword length] > 5)&&([self.retypeNewPassword length] > 5)) {
        if ([self.usersNewPassword isEqualToString:self.retypeNewPassword]) {
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

- (void) eraseTextFieldsText {
    [(UITextField *)[self.view viewWithTag:kCurrentPasswordTextFieldTag]setText:@""];
    [(UITextField *)[self.view viewWithTag:kNewPasswordTextFieldTag]setText:@""];
    [(UITextField *)[self.view viewWithTag:kRetypeNewPasswordTextFieldTag]setText:@""];
    
    [self.scrollView scrollsToTop];
    self.scrollView.scrollEnabled = NO;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    self.scrollView.scrollEnabled = YES;
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    switch (textField.tag) {
        case 101: 
            [(UITextField *)[self.view viewWithTag:102]becomeFirstResponder];
            break;
        case 102: 
            [(UITextField *)[self.view viewWithTag:103]becomeFirstResponder];
            break;
        case 103: 
            [self changePassword];
            break;
        default:
            break;
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

- (void) setUpPasswordsValues {
    self.currentPassword = ((UITextField *)[self.view viewWithTag:kCurrentPasswordTextFieldTag]).text;
    self.usersNewPassword = ((UITextField *)[self.view viewWithTag:kNewPasswordTextFieldTag]).text;
    self.retypeNewPassword = ((UITextField *)[self.view viewWithTag:kRetypeNewPasswordTextFieldTag]).text;
}

#pragma mark - TableView datasource

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 2;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    if (section == 0) {
        return 1;
    }
    else {
        return 2;
    }
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSString* identefier = @"";
   
    if (indexPath.section == 0) {
        identefier = kOldPasswordCellIdentifier;
    }
    else {
        identefier = (indexPath.row == 0) ? kNewPasswordCellIdentifier : kRetypeNewPasswordCellIdentifier;
    }

    PasswordCell * cell = [tableView dequeueReusableCellWithIdentifier: identefier];
    return cell;
}

@end
