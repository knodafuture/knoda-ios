//
//  NewImageCropperViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/14/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "NewImageCropperViewController.h"
#import "BJImageCropper.h"  
#import "LoadingView.h"
#import "UserManager.h"
#import "StartPredictingViewController.h"

static const float kAvatarSize = 344.0;
#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)

@interface NewImageCropperViewController ()
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) BJImageCropper *cropView;
@end

@implementation NewImageCropperViewController

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    self.image = image;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CROP";
    
    self.view.backgroundColor = [UIColor blackColor];
    self.cropView = [[BJImageCropper alloc] initWithImage:self.image andMaxSize:CGSizeMake(self.view.frame.size.width,
                                                                                           self.view.frame.size.height - 44.0/*nav bar height*/)];
    self.cropView.crop   = CGRectMake(0, 0, AVATAR_SIZE.width, AVATAR_SIZE.height);
    self.cropView.center = CGPointMake(self.view.center.x, self.view.center.y - 100.0);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Done" target:self action:@selector(sendAvatar) color:[UIColor whiteColor]];
    self.title = @"CROP";
    self.navigationController.navigationBar.translucent = NO;
    [self.view addSubview:self.cropView];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = NO;
}

- (void)sendAvatar {
    [[LoadingView sharedInstance] show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIImage *image = [self.cropView getCroppedImage];
        if(!CGSizeEqualToSize(image.size, AVATAR_SIZE)) {
            image = [image scaledToSize:AVATAR_SIZE autoScale:NO];
        }
        [[UserManager sharedInstance] uploadProfileImage:image completion:^(User *user, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (error) {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:error.localizedDescription != nil ? error.localizedDescription : @"An Unknown Error Occured."
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                  otherButtonTitles:nil] show];
                return;
            }
            //start predicting
            StartPredictingViewController *vc = [[StartPredictingViewController alloc] initWithImage:image];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
    });

}
@end
