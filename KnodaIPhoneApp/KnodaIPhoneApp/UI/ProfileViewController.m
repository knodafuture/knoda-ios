//
//  ProfileViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ProfileViewController.h"
#import "PreditionCell.h"
#import "NavigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "SignOutWebRequest.h"
#import "AppDelegate.h"

static NSString * const accountDetailsTableViewCellIdentifier = @"accountDetailsTableViewCellIdentifier";

@interface ProfileViewController ()

@property (nonatomic, strong) AppDelegate * appDelegate;
@property (nonatomic, strong) NSArray * accountDetailsArray;

@end

@implementation ProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern"]];
    self.accountDetailsTableView.backgroundView = nil;
    [self makeProfileImageRoundedCorners];
    [self fillInUsersInformation];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (void) makeProfileImageRoundedCorners {
    self.profileAvatarView.layer.cornerRadius = 10.0;
    self.profileAvatarView.layer.masksToBounds = YES;
    self.profileAvatarView.layer.borderWidth = 2.0;
    self.profileAvatarView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void) fillInUsersInformation {
    User * user = self.appDelegate.user;
    [self.profileAvatarView bindToURL:user.bigImage];
    self.loginLabel.text = user.name;
    self.pointsLabel.text = [NSString stringWithFormat:@"%d points",user.points];    
    self.accountDetailsArray = [NSArray arrayWithObjects:self.appDelegate.user.name,user.email,@"Change Password", nil];
    [self.accountDetailsTableView reloadData];
}
- (IBAction)signOut:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Cancel", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)menuButtonPress:(id)sender {
    [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
}

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SignOutSegue"])
    {
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate removePassword];
        
        SignOutWebRequest * signOutWebRequest = [[SignOutWebRequest alloc]init];
        [signOutWebRequest executeWithCompletionBlock:^{
        }];
    }
}

#pragma mark - UIActionSheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"SignOutSegue" sender:self];
    }
    else {
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    }
}

#pragma mark - TableView datasource

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"ChangePasswordSegue" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TableView datasource

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return [self.accountDetailsArray count];
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:accountDetailsTableViewCellIdentifier];
    if (!cell) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountDetailsTableViewCellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.accountDetailsArray[indexPath.row];
    return cell;
}

@end
