//
//  CreateGroupViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/21/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "WebApi.h"
#import "LoadingView.h"
#import "UserManager.h"
#import "ImageCropperViewController.h"
#import "GroupSettingsViewController.h"

NSString *GroupChangedNotificationName = @"GORUPCHANGED";
NSString *GroupChangedNotificationKey = @"CHANGEGROUP";

#define TEXT_FONT        [UIFont fontWithName:@"HelveticaNeue" size:15]
#define PLACEHOLDER_FONT [UIFont fontWithName:@"HelveticaNeue" size:15]
static const int kPredictionCharsLimit = 140;
static const int kMaxNameChars = 29;
static const float kAvatarSize = 344.0;
#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)

@interface CreateGroupViewController () <ImageCropperDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate>
@property (strong, nonatomic) Group *group;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *groupDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *messageCounterLabel;
@property (weak, nonatomic) IBOutlet UIView *groupImagePrompt;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (strong, nonatomic) UIActionSheet *avatarChangeAcitonSheet;
@property (strong, nonatomic) UIImage *startImage;
@property (strong, nonatomic) NSString *placeholderText;
@property (assign, nonatomic) BOOL showPlaceholder;
@end

@implementation CreateGroupViewController

- (id)initWithGroup:(Group *)group {
    self = [super initWithNibName:@"CreateGroupViewController" bundle:[NSBundle mainBundle]];
    self.group = group;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.placeholderText = NSLocalizedString(@"Group description...", @"");
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self action:@selector(submit) color:[UIColor whiteColor]];
    
    if (self.group) {
        self.title = @"EDIT GROUP";
        _showPlaceholder = false;
        self.groupNameTextField.text = self.group.name;
        self.groupDescriptionTextView.text = self.group.groupDescription;
        self.groupImagePrompt.hidden = YES;
        [[WebApi sharedInstance] getImage:self.group.avatar.big completion:^(UIImage *image, NSError *error) {
            if (image && !error) {
                self.groupImageView.image = image;
                self.startImage = image;
            } else {
                self.groupImagePrompt.hidden = NO;
            }
        }];
    } else {
        self.title = @"NEW GROUP";
        self.showPlaceholder = YES;
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)validate {
    NSString *errorMessage = nil;
    
    if (self.groupDescriptionTextView.text.length == 0 || self.showPlaceholder)
        errorMessage = NSLocalizedString(@"Please enter a description", @"");
    else if (self.groupNameTextField.text.length == 0)
        errorMessage = @"Please enter a group name";
    if (errorMessage != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message: errorMessage delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    return YES;
}
- (void)submit {
    
    if (![self validate])
        return;
    
    [self.view endEditing:YES];
    
    [[LoadingView sharedInstance] show];
    
    if (self.group) {
        self.group.name = self.groupNameTextField.text;
        self.group.groupDescription = self.groupDescriptionTextView.text;
        
        [[WebApi sharedInstance] updateGroup:self.group completion:^(Group *newGroup, NSError *error) {
            if (!error)
                self.group = newGroup;
            if (self.groupImageView.image != self.startImage) {
                if (self.groupImageView.image == nil) {
                    [[WebApi sharedInstance] deleteGroupAvatar:self.group completion:^(NSError *error) {
                        [[WebApi sharedInstance] getGroup:self.group.groupId completion:^(Group *group, NSError *error) {
                            self.group = group;
                            [self finish:nil];
                        }];
                    }];
                } else {
                    [[WebApi sharedInstance] uploadImageForGroup:newGroup image:self.groupImageView.image completion:^(Group *finalGroup, NSError *error) {
                        self.group = finalGroup;
                        [self finish:nil];
                    }];
                }
                return;
            }
            
            [self finish:newGroup];
        }];
    } else {
        Group *group = [[Group alloc] init];
        group.name = self.groupNameTextField.text;
        group.groupDescription = self.groupDescriptionTextView.text;
        
        [[WebApi sharedInstance] createGroup:group completion:^(Group *newGroup, NSError *error) {
            if (self.groupImageView.image != nil) {
                [[WebApi sharedInstance] uploadImageForGroup:newGroup image:self.groupImageView.image completion:^(Group *finalGroup, NSError *error) {
                    [self finish:finalGroup];
                }];
            } else {
                [self finish:newGroup];
            }
        }];
    }
}

- (void)finish:(Group *)createdGroup {
    [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        NSDictionary *userInfo;
        if (self.group)
            userInfo = @{GroupChangedNotificationKey: self.group};
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupChangedNotificationName object:self userInfo:userInfo];
        if (self.group) {
            [self back];
        } else {
            GroupSettingsViewController *vc = [[GroupSettingsViewController alloc] initWithNewlyCreatedGroup:createdGroup];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }];
}
- (void)setShowPlaceholder:(BOOL)showPlaceholder {
    _showPlaceholder = showPlaceholder;
    self.groupDescriptionTextView.textColor = _showPlaceholder ? [UIColor colorFromHex:@"CBCBD0"] : [UIColor blackColor];
    self.groupDescriptionTextView.text = _showPlaceholder ? self.placeholderText : @"";
    self.groupDescriptionTextView.font = _showPlaceholder ? PLACEHOLDER_FONT : TEXT_FONT;
}
- (IBAction)avatarImageVIewTapped:(id)sender {
    if (!self.avatarChangeAcitonSheet) {
        self.avatarChangeAcitonSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Take Photo", @""), NSLocalizedString(@"Choose Existing Photo", @""), NSLocalizedString(@"Use Default", @""), nil];
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
    
    [self.view.window.rootViewController presentViewController:pickerVC animated:YES completion:^{
        [UINavigationBar setCustomAppearance];
    }];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UINavigationBar setCustomAppearance];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        if(img) {
            if(img.size.width < kAvatarSize || img.size.height < kAvatarSize) {
                img = [img scaledToSize:AVATAR_SIZE autoScale:NO];
            }
            if(CGSizeEqualToSize(img.size, AVATAR_SIZE)) {
                self.groupImageView.image = img;
            }
            else {
                ImageCropperViewController *vc = [[ImageCropperViewController alloc] initWithNibName:@"ImageCropperViewController" bundle:[NSBundle mainBundle]];
                vc.image    = img;
                vc.delegate = self;
                vc.cropSize = AVATAR_SIZE;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [UINavigationBar setCustomAppearance];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ImageCropperDelegate

- (void)imageCropperDidCancel:(ImageCropperViewController *)vc {
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropper:(ImageCropperViewController *)vc didCroppedImage:(UIImage *)image {
    if(!CGSizeEqualToSize(image.size, AVATAR_SIZE)) {
        image = [image scaledToSize:AVATAR_SIZE autoScale:NO];
    }
    self.groupImageView.image = image;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
        NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (resultString.length > kMaxNameChars) {
            resultString = [resultString substringToIndex: kMaxNameChars - 1];
            textField.text = resultString;
            return NO;
        }
    return YES;
}

#pragma mark - UIActionSheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: //take photo
        case 1: //choose existing photo
            [self showImagePickerWithSource:(buttonIndex ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera)];
            break;
        case 2: //skip
        {
            self.groupImageView.image = nil;
            self.groupImagePrompt.hidden = NO;
        }
        default: //continue
            break;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSInteger len = textView.text.length - range.length + text.length;
    
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    
    if(len <= kPredictionCharsLimit) {
        self.messageCounterLabel.text = [NSString stringWithFormat:@"%ld", (long)(self.showPlaceholder ? kPredictionCharsLimit : (kPredictionCharsLimit - len))];
        return YES;
    }
    
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if(self.showPlaceholder) {
        self.showPlaceholder = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(!textView.text.length)
        self.showPlaceholder = YES;
}

@end
