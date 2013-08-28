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
#import "ProfileWebRequest.h"
#import "UsernameEmailChangeViewController.h"
#import "AddPredictionViewController.h"

static NSString * const accountDetailsTableViewCellIdentifier = @"accountDetailsTableViewCellIdentifier";

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";
static NSString* const kChangeEmailUsernameSegue = @"UsernameEmailSegue";
static NSString* const kChangePasswordSegue = @"ChangePasswordSegue";

@interface ProfileViewController () <AddPredictionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (nonatomic, strong) AppDelegate * appDelegate;
@property (nonatomic, strong) NSArray * accountDetailsArray;
@property (weak, nonatomic) IBOutlet UIButton *leftNavigationBarItem;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern"]];
    self.accountDetailsTableView.backgroundView = nil;
    [self makeProfileImageRoundedCorners];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    
    if (self.leftButtonItemReturnsBack) {
        [self.leftNavigationBarItem setImage:[UIImage imageNamed:@"backArrow.png"] forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fillInUsersInformation];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (void) makeProfileImageRoundedCorners {
    self.profileAvatarView.layer.cornerRadius = 10.0;
    self.profileAvatarView.layer.masksToBounds = YES;
    self.profileAvatarView.layer.borderWidth = 2.0;
    self.profileAvatarView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void) fillInUsersInformation {
    self.activityView.hidden = NO;
    ProfileWebRequest *profileWebRequest = [[ProfileWebRequest alloc]init];
    [profileWebRequest executeWithCompletionBlock:^{
        self.activityView.hidden = YES;
        
        if (profileWebRequest.isSucceeded)
        {
            [self.appDelegate.user updateWithObject:profileWebRequest.user];
        }
        
        User * user = self.appDelegate.user;
        [self.profileAvatarView bindToURL:user.bigImage];
        self.loginLabel.text = user.name;
        self.pointsLabel.text = [NSString stringWithFormat:@"%d %@",user.points,NSLocalizedString(@"points", @"")];
        self.accountDetailsArray = [NSArray arrayWithObjects:self.appDelegate.user.name,user.email,NSLocalizedString(@"Change Password", @""), nil];
        [self.accountDetailsTableView reloadData];
    }];
}

- (IBAction)signOut:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Are you sure you want to log out?", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Cancel", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)menuButtonPress:(id)sender {
    if (self.leftButtonItemReturnsBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [((NavigationViewController*)self.navigationController.parentViewController) toggleNavigationPanel];
    }
}

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kAddPredictionSegue]) {
        AddPredictionViewController *vc =(AddPredictionViewController*)segue.destinationViewController;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:kChangeEmailUsernameSegue]) {        
        UsernameEmailChangeViewController *vc =(UsernameEmailChangeViewController*)segue.destinationViewController;
        vc.userProperyChangeType = [sender integerValue];
    }
}

#pragma mark - UIActionSheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.appDelegate logout];
    }
    else {
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    }
}

#pragma mark - TableView datasource

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:kChangeEmailUsernameSegue sender:@(UserPropertyTypeUsername)];
            break;
        case 1:
            [self performSegueWithIdentifier:kChangeEmailUsernameSegue sender:@(UserPropertyTypeEmail)];
            break;
        case 2:
            [self performSegueWithIdentifier:kChangePasswordSegue sender:self];
            break;
        default:
            break;
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

#pragma mark - AddPredictionViewControllerDelegate

- (void) predictionWasMadeInController:(AddPredictionViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end
