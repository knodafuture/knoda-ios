//
//  SelectPictureViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 19.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SelectPictureViewController.h"
#import "UIImage+Utils.h"
#import "ImageCropperViewController.h"
#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "WebApi.h"
#import "UserManager.h"

static const int kDefaultAvatarsCount = 5;

static const float kAvatarSize = 344.0;
#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)

static NSString* const kImageCropperSegue = @"ImageCropperSegue";

@interface SelectPictureViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropperDelegate>

@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic) UIImage *avatarImage;
@property (nonatomic, assign) BOOL hasAppeared;
@property (strong, nonatomic) NSString *baseImageName;

@end

@implementation SelectPictureViewController

#pragma mark View lifecycle


- (id)initWithBaseDefaultImageName:(NSString *)baseImageName {
    self = [super initWithNibName:@"SelectPictureViewController" bundle:[NSBundle mainBundle]];
    self.baseImageName = baseImageName;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.doneButton = self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Done" target:self action:@selector(doneButtontapped:) color:[UIColor whiteColor]];
    self.title = @"KNODA";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.hasAppeared) {
        [self pictureButtonTapped:nil];
        self.hasAppeared = YES;
    }
}

- (void)setAvatarImage:(UIImage *)avatarImage {
    _avatarImage = avatarImage;
    self.doneButton.enabled = _avatarImage != nil;
    [self.pictureButton setImage:_avatarImage forState:UIControlStateNormal];
}

#pragma mark Actions

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.delegate hideViewController:self];
}

- (IBAction)pictureButtonTapped:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Use Default", @"")
                   destructiveButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"Take Photo", @""), NSLocalizedString(@"Choose Existing Photo", @""), nil] showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)doneButtontapped:(id)sender {
    [self sendAvatar];
}

- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType {
    
    if(![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        DLog(@"UIImagePickerController sourceType (%ld) unavailable",(long) sourceType);
        return;
    }
    
    UIImagePickerController *pickerVC = [UIImagePickerController new];
    
    pickerVC.sourceType    = sourceType;
    pickerVC.allowsEditing = NO;
    pickerVC.delegate      = self;
    [UINavigationBar setDefaultAppearance];
    
    [self presentViewController:pickerVC animated:YES completion:nil];
}

- (void)setDefaultAvatar {
    NSString *imgName = [NSString stringWithFormat:@"%@_%d.png", self.baseImageName, (arc4random() % kDefaultAvatarsCount + 1)];
    self.avatarImage = [UIImage imageNamed:imgName];
}

- (void)sendAvatar {
    [[LoadingView sharedInstance] show];
    [[UserManager sharedInstance] uploadProfileImage:self.avatarImage completion:^(User *user, NSError *error) {
        if (error)
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.delegate hideViewController:self];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: //take photo
        case 1: //choose existing photo
            [self showImagePickerWithSource:(buttonIndex ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera)];
            break;
        default: //continue
            [self setDefaultAvatar];
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UINavigationBar setCustomAppearance];
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        if(img) {
            if(img.size.width < kAvatarSize || img.size.height < kAvatarSize)
                img = [img scaledToSize:AVATAR_SIZE autoScale:NO];
            if(CGSizeEqualToSize(img.size, AVATAR_SIZE))
                self.avatarImage = img;
            else
                [self showImageCropperViewContoller:img];
        }
    }];
}

- (void)showImageCropperViewContoller:(UIImage *)image {
    ImageCropperViewController *vc = [[ImageCropperViewController alloc] initWithNibName:@"ImageCropperViewController" bundle:[NSBundle mainBundle]];
    vc.image    = image;
    vc.delegate = self;
    vc.cropSize = AVATAR_SIZE;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
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
    self.avatarImage = image;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end
