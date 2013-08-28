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
#import "PasswordCell.h"

@interface UsernameEmailChangeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButtonItem;

@end

@implementation UsernameEmailChangeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern"]];
    self.tableView.backgroundView = nil;
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    UIColor * darkGreen = [UIColor colorWithRed:36/255.0 green:112/255.0 blue:66/255.0 alpha:1];
    [self.rightButtonItem setTitleTextAttributes:@{UITextAttributeTextColor : darkGreen} forState:UIControlStateNormal];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButonTouched:(id)sender {
    [self saveNewProperyValue];
}

- (void) saveNewProperyValue {
    PasswordCell *cell = (PasswordCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.passWordTextField resignFirstResponder];
    NSString * newPropertyValue = cell.passWordTextField.text;
    
    ProfileWebRequest * webRequest = nil;
    if (self.userProperyChangeType == UserPropertyTypeEmail) {
        webRequest = [[ProfileWebRequest alloc]initWithNewEmail:newPropertyValue];
    }
    else if (self.userProperyChangeType == UserPropertyTypeUsername) {
        webRequest = [[ProfileWebRequest alloc]initWithNewUsername:newPropertyValue];
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
                                        message:webRequest.userFriendlyErrorDescription
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

#pragma mark - TableView datasource

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return 1;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSString *cellIdentifier = nil;
    switch (self.userProperyChangeType) {
        case UserPropertyTypeEmail:
            cellIdentifier = @"EmailCell";
            break;
        case UserPropertyTypeUsername:
            cellIdentifier = @"UserNameCell";
            break;
        default:
            break;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    return cell;
}

@end
