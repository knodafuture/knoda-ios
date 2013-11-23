//
//  ProfileViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ProfileViewController.h"
#import "PredictionCell.h"
#import "NavigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "AppDelegate.h"
#import "ProfileWebRequest.h"
#import "UIImage+Utils.h"
#import "ImageCropperViewController.h"
#import "BindableView.h"
#import "LoadingView.h"
#import "UserProfileHeaderView.h"

static NSString* const kChangeEmailUsernameSegue = @"UsernameEmailSegue";
static NSString* const kChangePasswordSegue = @"ChangePasswordSegue";
static NSString* const kImageCropperSegue = @"ImageCropperSegue";

static const int kDefaultAvatarsCount = 5;

static const float kAvatarSize = 344.0;
#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)

@interface ProfileViewController () <ImageCropperDelegate, UITextFieldDelegate>

@property (nonatomic, strong) AppDelegate * appDelegate;
@property (weak, nonatomic) IBOutlet UIButton *leftNavigationBarItem;
@property (nonatomic, strong) UIActionSheet *avatarChangeAcitonSheet;
@property (strong, nonatomic) UserProfileHeaderView *headerView;

@property (weak, nonatomic) IBOutlet UIView *userNameContainer;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UIView *emailContainer;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (assign, nonatomic) BOOL canceledEntry;


@end

@implementation ProfileViewController

- (void)dealloc {
    [self cancelAllRequests];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.leftButtonItemReturnsBack)
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(menuButtonPress:)];
    else
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem sideNavBarBUttonItemwithTarget:self action:@selector(menuButtonPress:)];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
    self.headerView = [[UserProfileHeaderView alloc] init];
    [self.view addSubview:self.headerView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageVIewTapped:)];
    [self.headerView.userAvatarView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:doneTap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadUserInformation];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    [Flurry logEvent: @"Profile_Screen" withParameters: nil timed: YES];
}

- (void)didTap {
    self.canceledEntry = YES;
    [self.view endEditing:YES];
}
- (void) viewDidDisappear: (BOOL) animated {
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"Profile_Screen" withParameters: nil];
}

- (void)populateUserInfo {
    
    User * user = self.appDelegate.user;
    
    self.title = user.name;
    
    [self.headerView populateWithUser:user];
    
    self.emailField.text = user.email;
    self.userNameField.text = user.name;
}

- (void)loadUserInformation {
    [[LoadingView sharedInstance] show];
    
    __weak ProfileViewController *weakSelf = self;
    
    ProfileWebRequest *profileWebRequest = [[ProfileWebRequest alloc]init];
    
    [self executeRequest:profileWebRequest withBlock:^{
        [[LoadingView sharedInstance] hide];
        
        ProfileViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if (profileWebRequest.isSucceeded)
        {
            [strongSelf.appDelegate.user updateWithObject:profileWebRequest.user];
        }
        
        [self populateUserInfo];
        
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

    [[LoadingView sharedInstance] show];
    
    __weak ProfileViewController *weakSelf = self;
    
    [self executeRequest:profileRequest withBlock:^{
        ProfileViewController *strongSelf = weakSelf;
        if(!strongSelf) {
            [[LoadingView sharedInstance] hide];
            return;
        }
        
        if(profileRequest.isSucceeded) {
            ProfileWebRequest *updateRequest = [ProfileWebRequest new];
            [updateRequest executeWithCompletionBlock:^{
                if(updateRequest.isSucceeded) {
                    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] updateWithObject:updateRequest.user];
                    strongSelf.headerView.userAvatarView.imageView.image = image;
                    [[LoadingView sharedInstance] hide];
                }
            }];
        }
        else {
            [[LoadingView sharedInstance] hide];
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
    if([segue.identifier isEqualToString:kImageCropperSegue]) {
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


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (!self.canceledEntry) {
        if (textField == self.userNameField)
            [self saveUsername];
        else
            [self saveEmail];
    }
    
    self.canceledEntry = NO;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    
    return YES;
}

- (void)saveUsername {
    
    ProfileWebRequest *webRequest = [[ProfileWebRequest alloc]initWithNewUsername:self.userNameField.text];
    
    [self updateUserWithRequest:webRequest];

}

- (void)saveEmail {
    NSString *emailRegex = @"\\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}\\b";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    NSInteger maxLength = 64;
    
    if (![emailPredicate evaluateWithObject:self.emailField.text] || self.emailField.text.length > maxLength) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid email address" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    ProfileWebRequest *webRequest = [[ProfileWebRequest alloc]initWithNewEmail:self.emailField.text];

    [self updateUserWithRequest:webRequest];


}

- (void)updateUserWithRequest:(ProfileWebRequest *)webRequest {
    [[LoadingView sharedInstance] show];

    [webRequest executeWithCompletionBlock:^{
        if(webRequest.isSucceeded) {
            ProfileWebRequest *updateRequest = [ProfileWebRequest new];
            [updateRequest executeWithCompletionBlock:^{
                [[LoadingView sharedInstance] hide];
                if(updateRequest.isSucceeded) {
                    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] updateWithObject:updateRequest.user];
                    [self populateUserInfo];
                }
            }];
        }
        else {
            [[LoadingView sharedInstance] hide];
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:webRequest.localizedErrorDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        }
        
    }];
}

@end
