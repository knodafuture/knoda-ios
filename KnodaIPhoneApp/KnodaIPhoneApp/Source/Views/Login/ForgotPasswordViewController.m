//
//  ForgotPasswordViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "LoadingView.h"
#import "WebApi.h"

@interface ForgotPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSString *email;

@end

@implementation ForgotPasswordViewController

- (id)initWithEmail:(NSString *)email {
    self = [super initWithNibName:@"ForgotPasswordViewController" bundle:[NSBundle mainBundle]];
    
    self.email = email;
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (self.email)
        self.textField.text = self.email;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backButtonPressed)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self action:@selector(sendButtonPressed) color:[UIColor whiteColor]];
}

#pragma mark - Actions

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated: YES];
}



- (void)sendButtonPressed {
    if (self.textField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[LoadingView sharedInstance] show];
    
    [self.view endEditing:YES];
    
    PasswordResetRequest *request = [[PasswordResetRequest alloc] init];
    request.login = self.textField.text;
    
    [[WebApi sharedInstance] requestPasswordReset:request completion:^(NSError *error) {
        [[LoadingView sharedInstance] hide];
        
        NSString *message;
        
        if (!error)
            message = @"A link to reset your password was sent to your email";
        else if (error.code == HttpStatusNotFound)
            message = @"Email was not found";
        else
            message = @"Unknown error. Please try later";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        if (!error)
            [self.navigationController popViewControllerAnimated:YES];
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textField)
        [self sendButtonPressed];
    
    return NO;
}
@end
