//
//  ForgotPasswordViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "CustomizedTextField.h"


@interface ForgotPasswordViewController ()

@property (nonatomic, strong) IBOutlet CustomizedTextField* textField;

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


- (IBAction) cancelButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}


- (IBAction) sendButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}


@end
