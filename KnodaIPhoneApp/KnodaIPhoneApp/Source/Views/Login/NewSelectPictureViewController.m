
//
//  NewSelectPictureViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/14/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NewSelectPictureViewController.h"
#import "ImageCropperViewController.h"
#import "WebApi.h"  
#import "LoadingView.h"
#import "UserManager.h"
#import "StartPredictingViewController.h"
#import "NewImageCropperViewController.h"

static const int kDefaultAvatarsCount = 5;

#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)


@interface NewSelectPictureViewController () <UIImagePickerControllerDelegate>
@property (strong, nonatomic) UIImage *avatarImage;
@end

@implementation NewSelectPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Skip" target:self action:@selector(skip) color:[UIColor whiteColor]];
    
    self.title = @"PROFILE";
}

- (IBAction)takePhoto:(id)sender {
    [self showImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)choosePhoto:(id)sender {
    [self showImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)skip {
    [self setDefaultAvatar];
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
    NSString *imgName = [NSString stringWithFormat:@"%@_%d.png", @"avatar", (arc4random() % kDefaultAvatarsCount + 1)];
    self.avatarImage = [UIImage imageNamed:imgName];
    self.imageView.image = self.avatarImage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
}

- (void)sendAvatar {
    [[LoadingView sharedInstance] show];
    [[UserManager sharedInstance] uploadProfileImage:self.avatarImage completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (error) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
            return;
        }
        StartPredictingViewController *vc = [[StartPredictingViewController alloc] initWithImage:self.avatarImage];
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UINavigationBar setCustomAppearance];
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        if(img) {
            NewImageCropperViewController *vc = [[NewImageCropperViewController alloc] initWithImage:img];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [UINavigationBar setCustomAppearance];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
