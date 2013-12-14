//
//  ProfileViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ProfileViewController.h"
#import "NavigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "UIImage+Utils.h"
#import "ImageCropperViewController.h"
#import "LoadingView.h"
#import "UserProfileHeaderView.h"
#import "WebApi.h"
#import "WebViewController.h"
#import "ChangePasswordViewController.h"

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
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (assign, nonatomic) BOOL canceledEntry;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.leftButtonItemReturnsBack)
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(menuButtonPress)];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem addPredictionBarButtonItem];
    
    self.headerView = [[UserProfileHeaderView alloc] init];
    [self.view insertSubview:self.headerView belowSubview:self.avatarButton];
    
    UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:doneTap];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadUserInformation];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [self observeProperty:@keypath(self.appDelegate.currentUser) withBlock:^(__weak id self, id old, id new) {
        [self populateUserInfo];
    }];
    [Flurry logEvent: @"Profile_Screen" withParameters: nil timed: YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeAllObservations];
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
    
    User *user = self.appDelegate.currentUser;
    
    self.title = user.name.uppercaseString;
    
    [self.headerView populateWithUser:user];
    
    self.emailField.text = user.email;
    self.userNameField.text = user.name;
}

- (void)loadUserInformation {
    [self populateUserInfo];
}

- (IBAction)signOut:(id)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Are you sure you want to log out?", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Cancel", nil];
    [actionSheet showInView:self.view];
}

- (void)menuButtonPress {
    if (self.leftButtonItemReturnsBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (AppDelegate*) appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (IBAction)termsPressed:(id)sender {
    WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.com/terms"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)privacyPolicyPressed:(id)sender {
    WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.com/privacy"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)changePasswordPressed:(id)sender {
    ChangePasswordViewController *vc = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}

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
    [UINavigationBar setDefaultAppearance];
    
    [self presentViewController:pickerVC animated:YES completion:nil];
}

- (void)sendAvatar:(UIImage *)image {
    UIImage *temporary = self.headerView.avatarImageView.image;
    
    self.headerView.avatarImageView.image = image;
    [[LoadingView sharedInstance] show];
    
    [[WebApi sharedInstance] uploadProfileImage:image completion:^(NSError *error) {
        [[LoadingView sharedInstance] hide];
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
            self.headerView.avatarImageView.image = temporary;
        }
    }];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UINavigationBar setCustomAppearance];
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
                ImageCropperViewController *vc = [[ImageCropperViewController alloc] initWithNibName:@"ImageCropperViewController" bundle:[NSBundle mainBundle]];
                vc.image    = img;
                vc.delegate = self;
                vc.cropSize = AVATAR_SIZE;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [UINavigationBar setCustomAppearance];
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
    
    [[LoadingView sharedInstance] show];
    [[WebApi sharedInstance] changeUsername:self.userNameField.text completion:^(NSError *error) {
        if (error)
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        
        [[LoadingView sharedInstance] hide];
        
    }];

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
    
    [[LoadingView sharedInstance] show];
    [[WebApi sharedInstance] changeEmail:self.emailField.text completion:^(NSError *error) {
        if (error)
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        
        [[LoadingView sharedInstance] hide];

    }];
}

@end
