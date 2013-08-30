//
//  UsernameEmailChangeViewController.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/28/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UsernameEmailChangeViewController.h"
#import "AppDelegate.h"
#import "ProfileWebRequest.h"
#import "CustomizedTextField.h"

@interface UsernameEmailChangeViewController ()

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButtonItem;
@property (weak, nonatomic) IBOutlet CustomizedTextField *userPropertyTextField;

@end

@implementation UsernameEmailChangeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern"]];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:5 forBarMetrics:UIBarMetricsDefault];

    UIColor * darkGreen = [UIColor colorWithRed:36/255.0 green:112/255.0 blue:66/255.0 alpha:1];
    [self.rightButtonItem setTitleTextAttributes:@{UITextAttributeTextColor : darkGreen} forState:UIControlStateNormal];
    [self setUpTextFieldPlaceHolder];
}

- (void) setUpTextFieldPlaceHolder {
    switch (self.userProperyChangeType) {
        case UserPropertyTypeEmail:
            self.userPropertyTextField.placeholder = NSLocalizedString(@"Email Address", @"");
            break;
        case UserPropertyTypeUsername:
            self.userPropertyTextField.placeholder = NSLocalizedString(@"User name", @"");
            break;
        default:
            break;
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButonTouched:(id)sender {
    [self saveNewProperyValue];
}

- (void) saveNewProperyValue {
    [self.userPropertyTextField resignFirstResponder];
    
    ProfileWebRequest * webRequest = nil;
    if (self.userProperyChangeType == UserPropertyTypeEmail) {
        webRequest = [[ProfileWebRequest alloc]initWithNewEmail:self.userPropertyTextField.text];
    }
    else if (self.userProperyChangeType == UserPropertyTypeUsername) {
        webRequest = [[ProfileWebRequest alloc]initWithNewUsername:self.userPropertyTextField.text];
    }
    
    self.loadingView.hidden = NO;
    
    [webRequest executeWithCompletionBlock:^{
        if(webRequest.isSucceeded) {
            ProfileWebRequest *updateRequest = [ProfileWebRequest new];
            [updateRequest executeWithCompletionBlock:^{
                if(updateRequest.isSucceeded) {
                    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] updateWithObject:updateRequest.user];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            self.loadingView.hidden = YES;
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:webRequest.localizedErrorDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        }
        
    }];
}

#pragma mark - TextField delegate 

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self saveNewProperyValue];
    return YES;
}

@end
