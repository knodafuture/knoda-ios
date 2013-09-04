//
//  SelectPictureViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 19.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SelectPictureViewController.h"
#import "ProfileWebRequest.h"
#import "UIImage+Utils.h"
#import "AppDelegate.h"
#import "ImageCropperViewController.h"
#import "LoadingView.h"

#import <QuartzCore/QuartzCore.h>

static const int kDefaultAvatarsCount = 5;

static const float kAvatarSize = 344.0;
#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)

static NSString* const kImageCropperSegue = @"ImageCropperSegue";

@interface SelectPictureViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropperDelegate>

@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic) UIImage *avatarImage;

@end

@implementation SelectPictureViewController

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pictureButton.imageView.layer.cornerRadius = 10.0;
    self.pictureButton.imageView.layer.masksToBounds = YES;
    
    [self pictureButtonTapped:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
                        cancelButtonTitle:NSLocalizedString(@"Continue", @"")
                   destructiveButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"Take Photo", @""), NSLocalizedString(@"Choose Existing Photo", @""), NSLocalizedString(@"Skip", @""), nil] showInView:self.view];
}

- (IBAction)doneButtontapped:(id)sender {
    [self sendAvatar];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:kImageCropperSegue]) {
        ImageCropperViewController *vc = (ImageCropperViewController *)segue.destinationViewController;
        vc.image    = sender;
        vc.delegate = self;
        vc.cropSize = AVATAR_SIZE;
    }
}

#pragma mark Private

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

- (void)setDefaultAvatar {
    NSString *imgName = [NSString stringWithFormat:@"avatar_%d.png", (arc4random() % kDefaultAvatarsCount + 1)];    
    self.avatarImage = [UIImage imageNamed:imgName];
}

- (void)sendAvatar {
    ProfileWebRequest *profileRequest = [[ProfileWebRequest alloc] initWithAvatar:self.avatarImage];
    
    [[LoadingView sharedInstance] show];
    
    [profileRequest executeWithCompletionBlock:^{
        if(profileRequest.isSucceeded) {
            ProfileWebRequest *updateRequest = [ProfileWebRequest new];
            [updateRequest executeWithCompletionBlock:^{
                [[LoadingView sharedInstance] hide];
                if(updateRequest.isSucceeded) {
                    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] updateWithObject:updateRequest.user];
                }
                [self.delegate hideViewController:self];
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

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: //take photo
        case 1: //choose existing photo
            [self showImagePickerWithSource:(buttonIndex ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera)];
            break;
        case 2: //skip
            [self setDefaultAvatar];
            [self sendAvatar];
        default: //continue
            if(!self.avatarImage) {
                [self setDefaultAvatar];
            }
            break;
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DLog(@"");
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        if(img) {
            if(img.size.width < kAvatarSize || img.size.height < kAvatarSize) {
                img = [img scaledToSize:AVATAR_SIZE autoScale:NO];
            }
            if(CGSizeEqualToSize(img.size, AVATAR_SIZE)) {
                self.avatarImage = img;
            }
            else {
                [self performSegueWithIdentifier:kImageCropperSegue sender:img];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DLog(@"");
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
