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

static NSString * const kOldPasswordCellIdentifier = @"OldPasswordCell";
static NSString * const kNewPasswordCellIdentifier = @"NewPasswordCell";
static NSString * const kRetypeNewPasswordCellIdentifier = @"NewPasswordRetypeCell";

static NSInteger const kKeyboardHeight = 216;

@interface ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet UITableView *passwordsTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSString *usersNewPassword;
@property (nonatomic, strong) NSString *currentPassword;
@property (nonatomic, strong) NSString *retypeNewPassword;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordsTableView.backgroundView = nil;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 130);
    self.scrollView.scrollEnabled = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern"]];
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
    ChangePasswordRequest * changePasswordRequest = [[ChangePasswordRequest alloc]initWithCurrentPassword:self.currentPassword newPassword:self.usersNewPassword];
    [changePasswordRequest executeWithCompletionBlock:^{
        
        [self eraseTextFieldsText];
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        if (changePasswordRequest.errorCode == 0) {
            alertView.title = @"Succes";
            alertView.message = @"Password has been changed succesfully";
        }
        else {
            alertView.title = @"Error";
            alertView.message = @"Old password is incorrect";
        }
        [alertView show];
    }];
}

#pragma mark - passwords chechs 

- (BOOL) passwordsFilledInCorrect {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    if (([self.currentPassword length] > 5)&&([self.usersNewPassword length] > 5)&&([self.retypeNewPassword length] > 5)) {
        if ([self.usersNewPassword isEqualToString:self.retypeNewPassword]) {
            return YES;
        }
        else {
            alertView.message = @"Passwords do not match";
            [alertView show];
            return NO;
        }
    }
    else {
        alertView.message = @"Minimum password length is 6 characters";
        [alertView show];
        return NO;
    }
}

#pragma mark - TextField delegate

- (void) eraseTextFieldsText {
    [(UITextField *)[self.view viewWithTag:101]setText:@""];
    [(UITextField *)[self.view viewWithTag:102]setText:@""];
    [(UITextField *)[self.view viewWithTag:103]setText:@""];
    
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

- (void) textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 101:
            self.currentPassword = textField.text;
            break;
        case 102:
            self.usersNewPassword = textField.text;
            break;
        case 103:
            self.retypeNewPassword = textField.text;
            break;
        default:
            break;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text length] > 20) {
        textField.text = [textField.text substringToIndex:19];
        return NO;
    }
    return YES;
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
