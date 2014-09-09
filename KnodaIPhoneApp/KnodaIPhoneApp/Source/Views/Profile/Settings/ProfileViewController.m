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
#import "WebApi.h"
#import "WebViewController.h"
#import "ChangePasswordViewController.h"
#import "UserManager.h"
#import "TwitterManager.h"
#import "FacebookManager.h" 
#import "UIActionSheet+Blocks.h"
#import "SettingsViewController.h"

static const int kDefaultAvatarsCount = 5;

static const float kAvatarSize = 344.0;
#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)

@interface ProfileViewController () <ImageCropperDelegate, UITextFieldDelegate>

@property (nonatomic, strong) AppDelegate * appDelegate;
@property (nonatomic, strong) UIActionSheet *avatarChangeAcitonSheet;

@property (weak, nonatomic) IBOutlet UIView *userNameContainer;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UIView *emailContainer;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (assign, nonatomic) BOOL canceledEntry;

@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.emailField.clearsOnBeginEditing = ![UserManager sharedInstance].user.email;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(menuButtonPress)];
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"PROFILE SETTINGS";
    
    UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:doneTap];
    
    self.twitterSwitch.onTintColor = [UIColor colorFromHex:@"2BA9E1"];
    self.twitterSwitch.tintColor = [UIColor colorFromHex:@"efefef"];
    self.facebookSwitch.tintColor = [UIColor colorFromHex:@"efefef"];
    self.facebookSwitch.onTintColor = [UIColor colorFromHex:@"3B5998"];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2.0;
    self.avatarImageView.clipsToBounds = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadUserInformation];

    [Flurry logEvent: @"Profile_Screen" withParameters: nil timed: YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    
    User *user = [UserManager sharedInstance].user;
    
    [[WebApi sharedInstance] getImage:user.avatar.big completion:^(UIImage *image, NSError *error) {
        if (image)
            self.avatarImageView.image = image;
    }];
    
    if (user.email && ![user.email isEqualToString:@""])
        self.emailField.text = user.email;
    else
        self.emailField.text = @"Add email";
    self.userNameField.text = user.name;
    
    if (user.phone && ![user.phone isEqualToString:@""])
        self.phoneNumberField.text = user.phone;
    else
        self.phoneNumberField.text = @"Add phone";
    
    
    if (user.twitterAccount != nil) {
        self.twitterLabel.text = [NSString stringWithFormat:@"@%@", user.twitterAccount.providerAccountName];
        self.twitterSwitch.on = YES;
    } else {
        self.twitterLabel.text = @"Connect to Twitter";
        self.twitterSwitch.on = NO;
    }
    
    if (user.facebookAccount != nil) {
        self.facebookLabel.text = user.facebookAccount.providerAccountName;
        self.facebookSwitch.on = YES;
    } else {
        self.facebookLabel.text = @"Connect to Facebook";
        self.facebookSwitch.on = NO;
    }
}

- (void)loadUserInformation {
    [self populateUserInfo];
}

- (void)menuButtonPress {
        [self.navigationController popViewControllerAnimated:YES];
}

- (AppDelegate*) appDelegate {
    return [UIApplication sharedApplication].delegate;
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
    [self.avatarChangeAcitonSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType {
    
    if(![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        DLog(@"UIImagePickerController sourceType (%ld) unavailable", (long)sourceType);
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
    UIImage *temporary = self.avatarImageView.image;
    
    self.avatarImageView.image = image;
    [[LoadingView sharedInstance] show];
    
    [[UserManager sharedInstance] uploadProfileImage:image completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
            self.avatarImageView.image = temporary;
        } else
            self.avatarImageView.image = image;
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
        else if (textField == self.emailField)
            [self saveEmail];
        else
            [self savePhone];
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
    User *user = [[UserManager sharedInstance].user copy];
    user.name = self.userNameField.text;
    [[UserManager sharedInstance] updateUser:user completion:^(User *user, NSError *error) {
        if (error)
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        
        [[LoadingView sharedInstance] hide];
    }];
}

- (void)savePhone {
    User *user = [[UserManager sharedInstance].user copy];
    user.phone = self.phoneNumberField.text;
    
    [[LoadingView sharedInstance] show];
    [[UserManager sharedInstance] updateUser:user completion:^(User *user, NSError *error) {
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
    
    User *user = [[UserManager sharedInstance].user copy];
    user.email = self.emailField.text;
    
    [[LoadingView sharedInstance] show];
    [[UserManager sharedInstance] updateUser:user completion:^(User *user, NSError *error) {
        if (error)
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        
        [[LoadingView sharedInstance] hide];
    }];
}

- (void)dealloc {
    [self removeAllObservations];
}


- (IBAction)twitterButtonPressed:(id)sender {
    if ([UserManager sharedInstance].user.twitterAccount)
        [self removeTwitterAccount];
    else
        [self addTwitterAccount];
}

- (IBAction)facebookButtonPressed:(id)sender {
    if ([UserManager sharedInstance].user.facebookAccount)
        [self removeFacebookAccount];
    else
        [self addFacebookAccount];
}

- (IBAction)twitterToggleValueChanged:(id)sender {
    [self twitterButtonPressed:sender];
}

- (IBAction)facebookToggleValueChanged:(id)sender {
    [self facebookButtonPressed:sender];
}

- (void)addTwitterAccount {
    [[LoadingView sharedInstance] show];
    [[TwitterManager sharedInstance] performReverseAuth:^(SocialAccount *request, NSError *error) {
        if (error) {
            [[LoadingView sharedInstance] hide];
            [self populateUserInfo];
            return;
        }
        
        [[UserManager sharedInstance] addSocialAccount:request completion:^(User *user, NSError *error) {
            [self populateUserInfo];
            [[LoadingView sharedInstance] hide];
            if (error)
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:error.localizedDescription
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                  otherButtonTitles:nil] show];
        }];
    }];
}

- (void)removeTwitterAccount {
    
    User *user = [UserManager sharedInstance].user;
    
    if ((!user.email || [user.email isEqualToString:@""]) && !user.facebookAccount) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You must enter an email address before removing your last social account, or your account will be lost forever." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [self populateUserInfo];
        return;
    }
    
    [UIActionSheet showInView:[UIApplication sharedApplication].keyWindow withTitle:@"Are you sure?" cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes, remove this account." otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            [self populateUserInfo];
            return;
        }
        [self twitterAccountRemovalConfirm];
    }];
}

- (void)twitterAccountRemovalConfirm {
    [[LoadingView sharedInstance] show];
    [[UserManager sharedInstance] deleteSocialAccount:[UserManager sharedInstance].user.twitterAccount completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        [self populateUserInfo];
        if (error)
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
    }];
}

- (void)addFacebookAccount {
    [[LoadingView sharedInstance] show];
    [[FacebookManager sharedInstance] openSession:^(NSDictionary *data, NSError *error) {
        if (error) {
            [[LoadingView sharedInstance] hide];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [self populateUserInfo];
            return;
        }
        SocialAccount *request = [[SocialAccount alloc] init];
        request.providerName = @"facebook";
        request.providerId = data[@"id"];
        request.accessToken = [[FacebookManager sharedInstance] accessTokenForCurrentSession];

        
        [[UserManager sharedInstance] addSocialAccount:request completion:^(User *user, NSError *error) {
            [self populateUserInfo];
            [[LoadingView sharedInstance] hide];
            if (error)
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:error.localizedDescription
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                  otherButtonTitles:nil] show];
        }];
    }];
}

- (void)removeFacebookAccount {
    User *user = [UserManager sharedInstance].user;
    
    if ((!user.email || [user.email isEqualToString:@""]) && !user.twitterAccount) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You must enter an email address before removing your last social account, or your account will be lost forever." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [self populateUserInfo];
        return;
    }
    
    [UIActionSheet showInView:[UIApplication sharedApplication].keyWindow withTitle:@"Are you sure?" cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes, remove this account." otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            [self populateUserInfo];
            return;
        }
        [self facebokAccountRemovalConfirm];
    }];
}

- (void)facebokAccountRemovalConfirm {
    [[LoadingView sharedInstance] show];
    [[UserManager sharedInstance] deleteSocialAccount:[UserManager sharedInstance].user.facebookAccount completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        [self populateUserInfo];
        if (error)
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
    }];
}


@end
