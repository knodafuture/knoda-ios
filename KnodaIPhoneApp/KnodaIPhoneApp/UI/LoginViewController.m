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

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}


- (IBAction) loginButtonPressed: (id) sender
{
    LoginWebRequest* loginRequest = [[LoginWebRequest alloc] initWithUsername: self.usernameTextField.text password: self.passwordTextField.text];
    [loginRequest executeWithCompletionBlock: ^
     {
         self.appDelegate.user = loginRequest.user;
         
         PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] init];
         [predictionsRequest executeWithCompletionBlock: ^{}];
     }];
}


@end
