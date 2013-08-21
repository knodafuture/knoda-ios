//
//  SelectPictureViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 19.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SelectPictureViewController.h"
#import "ProfileWebRequest.h"

static const int kDefaultAvatarsCount = 5;

@interface SelectPictureViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIImage *avatarImage;

@end

@implementation SelectPictureViewController

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self pictureButtonTapped:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setAvatarImage:(UIImage *)avatarImage {
    _avatarImage = avatarImage;
    self.doneButton.enabled = _avatarImage != nil;
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

#pragma mark Private

- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType {
    
    if(![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        DLog(@"UIImagePickerController sourceType (%d) unavailable", sourceType);
        return;
    }
    
    UIImagePickerController *pickerVC = [UIImagePickerController new];
    
    pickerVC.sourceType        = sourceType;
    pickerVC.allowsEditing     = NO;
    pickerVC.delegate          = self;
    
    [self presentViewController:pickerVC animated:YES completion:nil];
}

- (void)setDefaultAvatar {
    NSString *imgName = [NSString stringWithFormat:@"avatar_%d.png", (arc4random() % kDefaultAvatarsCount + 1)];    
    self.avatarImage = [UIImage imageNamed:imgName];
    [self.pictureButton setImage:self.avatarImage forState:UIControlStateNormal];
}

- (void)sendAvatar {
    ProfileWebRequest *profileRequest = [[ProfileWebRequest alloc] initWithAvatar:self.avatarImage];
    //TODO: add activity indicator
    [profileRequest executeWithCompletionBlock:^{
        if(profileRequest.isSucceeded) {
            [self.delegate hideViewController:self];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:profileRequest.userFriendlyErrorDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        case 1:
            [self showImagePickerWithSource:(buttonIndex ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera)];
            break;
        default:
            [self setDefaultAvatar];
            break;
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DLog(@"");
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        if(img) {
            self.avatarImage = [[self class] imageWithImage:img scaledToSize:self.pictureButton.frame.size];
            [self.pictureButton setImage:self.avatarImage forState:UIControlStateNormal];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DLog(@"");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
