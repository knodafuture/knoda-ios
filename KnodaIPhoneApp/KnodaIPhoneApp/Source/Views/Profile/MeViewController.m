//
//  MeViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/16/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "MeViewController.h"
#import "UserManager.h"
#import "SettingsViewController.h"
#import "UserProfileHeaderView.h"
#import "MeTableViewController.h"
#import "NavigationScrollView.h"
#import "ImageCropperViewController.h"
#import "LoadingView.h"
#import "FacebookManager.h"
#import "TwitterManager.h"
#import "UIActionSheet+Blocks.h"
#import "FollowersViewController.h"
#import "NavigationViewController.h"
#import "RivalsViewController.h"


static const float kAvatarSize = 344.0;
#define AVATAR_SIZE CGSizeMake(kAvatarSize, kAvatarSize)
static const int kDefaultAvatarsCount = 5;


CGFloat const SwipeBezel = 30.0f;

@interface MeViewController () <NavigationViewControllerDelegate, UIScrollViewDelegate, MeTableViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImageCropperDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet NavigationScrollView *scrollView;
@property (strong, nonatomic) UserProfileHeaderView *headerView;
@property (strong, nonatomic) NSArray *buttons;
@property (strong, nonatomic) NSArray *tableViewControllers;
@property (weak, nonatomic) MeTableViewController *visibleTableViewController;
@property (strong, nonatomic) UIView *selectionView;
@property (strong, nonatomic) UIView *buttonsContainer;
@property (assign, nonatomic) NSInteger activePage;
@property (assign, nonatomic) BOOL setup;
@property (strong, nonatomic) UIActionSheet *avatarChangeAcitonSheet;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [UserManager sharedInstance].user.name.uppercaseString;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"SettingsIcon"] target:self action:@selector(onSettings)];

    self.selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    self.selectionView.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    
    UILabel *myPredictionsLabel = [self headerLabel];
    myPredictionsLabel.text = @"My Predictions";
    
    UILabel *myVotesLabel = [self headerLabel];
    myVotesLabel.text = @"My Votes";
    
    self.buttons = @[myPredictionsLabel, myVotesLabel];
    
    MeTableViewController *myPredictions = [[MeTableViewController alloc] initForChallenged:NO delegate:self];
    MeTableViewController *myVotes = [[MeTableViewController alloc] initForChallenged:YES delegate:self];
    
    self.headerView = [[UserProfileHeaderView alloc] initWithDelegate:self showHeadToHead:NO];
    self.headerView.hidden = YES;
    [self.headerView populateWithUser:[UserManager sharedInstance].user];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged:) name:UserChangedNotificationName object:nil];
    
    [self.view insertSubview:self.headerView atIndex:0];
    
    self.tableViewControllers = @[myPredictions, myVotes];
    
    self.scrollView.bezelWidth = SwipeBezel;
    
    self.scrollView.scrollsToTop = NO;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftBarButtonItemWithImage:[UIImage imageNamed:@"HeadtoHeadIcon"] target:self action:@selector(onRivals)];
}

- (void)userChanged:(NSNotification *)notification {
    [self.headerView populateWithUser:[UserManager sharedInstance].user];
}

- (UITableView *)tableView {
    return self.visibleTableViewController.tableView;
}

- (void)onSettings {
    SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:nav animated:YES completion:nil];
}

- (void)onRivals {
    RivalsViewController *vc = [[RivalsViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.setup)
        return;
    
    self.setup = YES;
    
    for (int i = 0; i < self.tableViewControllers.count; i++){
        MeTableViewController *vc = self.tableViewControllers[i];
        CGRect frame = vc.view.frame;
        frame.size = self.scrollView.frame.size;
        frame.origin.y = 0;
        frame.origin.x = i * frame.size.width;
        vc.view.frame = frame;
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
    }
    
    self.visibleTableViewController = self.tableViewControllers[0];
    
    [self.view addSubview:self.selectionView];
    
    CGRect frame = self.selectionView.frame;
    
    frame.origin.y = self.headerView.frame.size.height + self.visibleTableViewController.tableView.contentOffset.y;
    
    self.selectionView.frame = frame;
    
    if (self.buttons.count == 0)
        return;
    
    UILabel *firstButton = self.buttons[0];
    UILabel *secondButton = self.buttons[1];
    
    frame = firstButton.frame;
    frame.origin.x = 0;
    frame.size.width = self.selectionView.frame.size.width / 2.0;
    firstButton.frame = frame;
    
    frame = secondButton.frame;
    frame.origin.x = self.selectionView.frame.size.width / 2.0;
    frame.size.width = frame.origin.x;
    secondButton.frame = frame;
    
    [self.selectionView addSubview:firstButton];
    [self.selectionView addSubview:secondButton];
    
    [self.buttons[0] setAlpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.tableViewControllers.count, self.view.frame.size.height);
}

- (void)viewDidAppearInNavigationViewController:(NavigationViewController *)viewController {
    [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {}];
}

- (void)viewDidDisappearInNavigationViewController:(NavigationViewController *)viewController {
    
}
- (void)tableViewDidScroll:(UIScrollView *)scrollView inTableViewController:(MeTableViewController *)viewController {
    if (viewController != self.visibleTableViewController)
        return;
    
    CGRect frame = self.selectionView.frame;
    
    frame.origin.y = MAX(self.headerView.frame.size.height - self.visibleTableViewController.tableView.contentOffset.y, 0);
    
    self.selectionView.frame = frame;
    
    for (MeTableViewController *vc in self.tableViewControllers) {
        if (vc == self.visibleTableViewController)
            continue;
        vc.tableView.contentOffset = CGPointMake(0, MIN(self.headerView.frame.size.height, scrollView.contentOffset.y));
    }
}

- (void)prepareHeadersForMove {
    CGRect frame = self.headerView.frame;
    
    frame.origin.y = MAX(-self.headerView.frame.size.height / 2.0, -self.visibleTableViewController.tableView.contentOffset.y * 0.5);
    
    self.headerView.frame = frame;
    
    self.headerView.hidden = NO;
    for (MeTableViewController *vc in self.tableViewControllers) {
        [vc setHeaderHidden:YES];
    }
}

- (void)finishHeadersFromMove {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    self.visibleTableViewController = self.tableViewControllers[page];
    
    self.headerView.hidden = YES;
    
    for (MeTableViewController *vc in self.tableViewControllers) {
        [vc setHeaderHidden:NO];
    }
    
    [self selectIndex:page];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self prepareHeadersForMove];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self finishHeadersFromMove];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self finishHeadersFromMove];
}

- (UILabel *)headerLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.selectionView.frame.size.width * .5, self.selectionView.frame.size.height)];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [label addGestureRecognizer:tap];
    label.alpha = 0.25;
    return label;
}

- (void)labelTapped:(UIGestureRecognizer *)sender {
    NSInteger index = [self.buttons indexOfObject:sender.view];
    UIViewController *vc = [self.tableViewControllers objectAtIndex:index];
    [self prepareHeadersForMove];
    
    
    [self.scrollView setContentOffset:CGPointMake(vc.view.frame.origin.x, 0) animated:YES];
    [self selectIndex:index];
}

- (void)selectIndex:(NSInteger)index {
    if (self.activePage == index)
        return;
    
    MeTableViewController *previous = self.tableViewControllers[self.activePage];
    previous.tableView.scrollsToTop = NO;
    UILabel *current = [self.buttons objectAtIndex:self.activePage];
    UILabel *next = [self.buttons objectAtIndex:index];
    
    [UIView animateWithDuration:0.5 animations:^{
        current.alpha = 0.25;
        next.alpha = 1.0;
    }];
    
    self.activePage = index;
    
    self.visibleTableViewController = self.tableViewControllers[index];
    self.visibleTableViewController.tableView.scrollsToTop = YES;
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
    
    [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:pickerVC animated:YES completion:nil];
}

- (void)sendAvatar:(UIImage *)image {
    [[LoadingView sharedInstance] show];
    
    [[UserManager sharedInstance] uploadProfileImage:image completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UINavigationBar setCustomAppearance];
    [picker dismissViewControllerAnimated:YES completion:^{
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
                [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [UINavigationBar setCustomAppearance];
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    if (actionSheet == self.avatarChangeAcitonSheet) {
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

- (void)avatarButtonPressedInHeaderView:(UserProfileHeaderView *)headerView {
    if (!self.avatarChangeAcitonSheet) {
        self.avatarChangeAcitonSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Take Photo", @""), NSLocalizedString(@"Choose Existing Photo", @""), NSLocalizedString(@"Set Default", @""), nil];
    }
    [self.avatarChangeAcitonSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)followersPressedInHeaderView:(UserProfileHeaderView *)headerView {
    
    FollowersViewController *vc = [[FollowersViewController alloc] initForUser:[UserManager sharedInstance].user.userId name:[UserManager sharedInstance].user.name];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)followingPressedInHeaderView:(UserProfileHeaderView *)headerView {
    FollowersViewController *vc = [[FollowersViewController alloc] initForUser:[UserManager sharedInstance].user.userId name:[UserManager sharedInstance].user.name];
    vc.shouldShowSecondPage = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)addTwitterAccount {
    [[LoadingView sharedInstance] show];
    [[TwitterManager sharedInstance] performReverseAuth:^(SocialAccount *request, NSError *error) {
        if (error) {
            [[LoadingView sharedInstance] hide];
            return;
        }
        
        [[UserManager sharedInstance] addSocialAccount:request completion:^(User *user, NSError *error) {
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
        return;
    }
    
    [UIActionSheet showInView:[UIApplication sharedApplication].keyWindow withTitle:@"Are you sure?" cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes, remove this account." otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        [self twitterAccountRemovalConfirm];
    }];
}

- (void)twitterAccountRemovalConfirm {
    [[LoadingView sharedInstance] show];
    [[UserManager sharedInstance] deleteSocialAccount:[UserManager sharedInstance].user.twitterAccount completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
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
            return;
        }
        SocialAccount *request = [[SocialAccount alloc] init];
        request.providerName = @"facebook";
        request.providerId = data[@"id"];
        request.accessToken = [[FacebookManager sharedInstance] accessTokenForCurrentSession];
        
        
        [[UserManager sharedInstance] addSocialAccount:request completion:^(User *user, NSError *error) {
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
        return;
    }
    
    [UIActionSheet showInView:[UIApplication sharedApplication].keyWindow withTitle:@"Are you sure?" cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes, remove this account." otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        [self facebokAccountRemovalConfirm];
    }];
}

- (void)facebokAccountRemovalConfirm {
    [[LoadingView sharedInstance] show];
    [[UserManager sharedInstance] deleteSocialAccount:[UserManager sharedInstance].user.facebookAccount completion:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (error)
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil] show];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
