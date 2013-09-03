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
#import "AppDelegate.h"
#import "ProfileWebRequest.h"
#import "UsernameEmailChangeViewController.h"
#import "AddPredictionViewController.h"
#import "UIImage+Utils.h"
#import "ImageCropperViewController.h"

static NSString * const accountDetailsTableViewCellIdentifier = @"accountDetailsTableViewCellIdentifier";

static NSString* const kAddPredictionSegue = @"AddPredictionSegue";
static NSString* const kChangeEmailUsernameSegue = @"UsernameEmailSegue";
static NSString* const kChangePasswordSegue = @"ChangePasswordSegue";
static NSString* const kImageCropperSegue = @"ImageCropperSegue";

static const int kDefaultAvatarsCount = 5;

static const float kAvatarSize = 344.0;
#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)

@interface ProfileViewController () <AddPredictionViewControllerDelegate, ImageCropperDelegate> {
    int _loadingsCount;
}

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (nonatomic, strong) AppDelegate * appDelegate;
@property (nonatomic, strong) NSArray * accountDetailsArray;
@property (weak, nonatomic) IBOutlet UIButton *leftNavigationBarItem;
@property (nonatomic, strong) UIActionSheet *avatarChangeAcitonSheet;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern"]];
    self.accountDetailsTableView.backgroundView = nil;
    [self makeProfileImageRoundedCorners];
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:5 forBarMetrics:UIBarMetricsDefault];

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
    [self showLoadingView];
    ProfileWebRequest *profileWebRequest = [[ProfileWebRequest alloc]init];
    [profileWebRequest executeWithCompletionBlock:^{
        [self hideLoadingView];
        
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

- (void)showLoadingView {
    self.activityView.hidden = NO;
    _loadingsCount++;
}

- (void)hideLoadingView {
    if(--_loadingsCount <= 0) {
        self.activityView.hidden = YES;
        _loadingsCount = 0;
    }
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

#pragma mark - Change Avatar

- (IBAction)avatarImageVIewTapped:(id)sender {
    if (!self.avatarChangeAcitonSheet) {
        self.avatarChangeAcitonSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Take Photo", @""), NSLocalizedString(@"Choose Existing Photo", @""), NSLocalizedString(@"Set Default", @""), nil];
    }
    [self.avatarChangeAcitonSheet showInView:self.view];
}

- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType {
    
    if(![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        DLog(@"UIImagePickerController sourceType (%d) unavailable", sourceType);
        return;
    }
    
    UIImagePickerController *pickerVC = [UIImagePickerController new];
    
    pickerVC.sourceType    = sourceType;
    pickerVC.allowsEditing = NO;
    pickerVC.delegate      = self;
    
    [self presentViewController:pickerVC animated:YES completion:nil];
}

- (void)sendAvatar:(UIImage *)image {
    ProfileWebRequest *profileRequest = [[ProfileWebRequest alloc] initWithAvatar:image];

    [self showLoadingView];
    
    [profileRequest executeWithCompletionBlock:^{
        if(profileRequest.isSucceeded) {
            ProfileWebRequest *updateRequest = [ProfileWebRequest new];
            [updateRequest executeWithCompletionBlock:^{
                if(updateRequest.isSucceeded) {
                    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] updateWithObject:updateRequest.user];
                    self.profileAvatarView.imageView.image = image;
                    [self hideLoadingView];
                }
            }];
        }
        else {
            [self hideLoadingView];
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:profileRequest.localizedErrorDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        if(img) {
            if(img.size.width < kAvatarSize || img.size.height < kAvatarSize) {
                img = [img scaledToSize:AVATAR_SIZE autoScale:NO];
            }
            if(CGSizeEqualToSize(img.size, AVATAR_SIZE)) {
                [self sendAvatar:img];
            }
            else {
                [self performSegueWithIdentifier:kImageCropperSegue sender:img];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ImageCropperDelegate

- (void)imageCropperDidCancel:(ImageCropperViewController *)vc {
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropper:(ImageCropperViewController *)vc didCroppedImage:(UIImage *)image {
    if(!CGSizeEqualToSize(image.size, AVATAR_SIZE)) {
        image = [image scaledToSize:AVATAR_SIZE autoScale:NO];
    }
    [self sendAvatar:image];
    [vc dismissViewControllerAnimated:YES completion:nil];
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
        vc.userProperyChangeType = [sender[0]integerValue];
        vc.currentPropertyValue = sender[1];
    }
    else if([segue.identifier isEqualToString:kImageCropperSegue]) {
        ImageCropperViewController *vc = (ImageCropperViewController *)segue.destinationViewController;
        vc.image    = sender;
        vc.delegate = self;
        vc.cropSize = AVATAR_SIZE;
    }
}

#pragma mark - UIActionSheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet != self.avatarChangeAcitonSheet) {
        if (buttonIndex == 0) {
            [self.appDelegate logout];
        }
        else {
            [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
        }
    }
    else {
        switch (buttonIndex) {
            case 0: //take photo
            case 1: //choose existing photo
                [self showImagePickerWithSource:(buttonIndex ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera)];
                break;
            case 2: //skip
            {
                NSString *imgName = [NSString stringWithFormat:@"avatar_%d.png", (arc4random() % kDefaultAvatarsCount + 1)];
                [self sendAvatar:[UIImage imageNamed:imgName]];
            }
            default: //continue
                break;
        }
    }
}

#pragma mark - TableView datasource

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:kChangeEmailUsernameSegue sender:@[@(UserPropertyTypeUsername),[tableView cellForRowAtIndexPath:indexPath].textLabel.text]];
            break;
        case 1:
            [self performSegueWithIdentifier:kChangeEmailUsernameSegue sender:@[@(UserPropertyTypeEmail),[tableView cellForRowAtIndexPath:indexPath].textLabel.text]];
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
