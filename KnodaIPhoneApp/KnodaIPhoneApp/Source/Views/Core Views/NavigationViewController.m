//
//  NavigationViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NavigationViewController.h"
#import "AppDelegate.h"
#import "SelectPictureViewController.h"
#import "LoadingView.h" 
#import "User+Utils.h"
#import "HomeViewController.h"
#import "MeViewController.h"
#import "PredictionsViewController.h"
#import "AddPredictionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchViewController.h"
#import "UserManager.h"
#import "NavigationScrollView.h"
#import "GroupSettingsViewController.h"
#import "NotificationSettingsViewController.h"
#import "NewActivityViewController.h"
#import "UIView+Utils.h"
#import "WalkthroughController.h"   
#import "CGViewController.h"
#import "WelcomeViewController.h"   
#import "UIImage+ImageEffects.h"
#import "NewHomeViewController.h"
#import "SocialInvitationsViewController.h"

CGFloat const SideNavBezelWidth = 50.0f;
NSString *UserLoggedInNotificationName = @"USERLOGGEDIN";
NSString *UserLoggedOutNotificationName = @"USERLOGGEDOUT";
NSString *GetStartedNotificationName = @"GETSTARTED";

@interface NavigationViewController () <UIScrollViewDelegate, SelectPictureDelegate, AddPredictionViewControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) BOOL appeared;
@property (assign, nonatomic) MenuItem activeMenuItem;
@property (strong, nonatomic) SelectPictureViewController *selectVc;
@property (readonly, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableDictionary *vcCache;

@property (strong, nonatomic) NSTimer *pingTimer;
@property (strong, nonatomic) UINavigationController *visibleViewController;

@property (readonly, nonatomic) UserManager *userManger;
@property (strong, nonatomic) Group *activeGroup;
@property (strong, nonatomic) NSDictionary *pushInfo;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIView *tabBarView;
@property (weak, nonatomic) IBOutlet NavigationScrollView *scrollView;
@property (strong, nonatomic) NSArray *buttonNames;
@property (strong, nonatomic) UINavigationController *welcomeNavigationController;
@property (strong, nonatomic) UIImageView *blurImageView;
@end

@implementation NavigationViewController

- (id)initWithPushInfo:(NSDictionary *)pushInfo {
    self = [super initWithNibName:@"NavigationViewController" bundle:[NSBundle mainBundle]];
    self.vcCache = [[NSMutableDictionary alloc] init];
    self.pushInfo = pushInfo;
    _userManger = [UserManager sharedInstance];
    self.tabBarEnabled = YES;
    self.buttonNames = @[@"NavHome", @"NavActivity", @"NavGroups", @"NavMe"];
    return self;
    
}
- (void) viewDidLoad {
    [super viewDidLoad];
    [self updateAlerts];
    self.scrollView.disabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeGroupChanged:) name:ActiveGroupChangedNotificationName object:nil];
    self.scrollView.scrollsToTop = NO;
    
    self.tabBarEnabled = [UserManager sharedInstance].user != nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processImage:) name:HomeViewLoadedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogin) name:UserLoggedInNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getStarted) name:GetStartedNotificationName object:nil];

}


- (void)handleOpenUrl:(NSURL *)url {
    
    NSString *host = [url host];
    if ([[url scheme] isEqualToString:@"knoda"]) {
    
        if ([host isEqualToString:@"predictions"]) {
            [self showPrediction:[[[url pathComponents] lastObject] integerValue]];
        }
    } else {
        NSRange locationOfShare = [url.path rangeOfString:@"/share"];
        if (locationOfShare.location == NSNotFound)
            return;
        NSString *newUrl = [NSString stringWithFormat:@"knoda:/%@", [url.path substringToIndex:[url.path rangeOfString:@"/share"].location]];
        [self handleOpenUrl:[NSURL URLWithString:newUrl]];
    }
}

- (void)handlePushInfo:(NSDictionary *)pushInfo {
    self.pushInfo = pushInfo;
    if (self.pushInfo) {
        if ([self.pushInfo[@"type"] isEqualToString:@"p"]) {
            [self showPrediction:[self.pushInfo[@"id"] integerValue]];
        } else if ([self.pushInfo[@"type"] isEqualToString:@"gic"]) {
            [self showInvite:[self.pushInfo[@"id"] stringValue]];
        }
    }
    
}

- (void)showInvite:(NSString *)inviteId {
    [[LoadingView sharedInstance] show];
    [[WebApi sharedInstance] getInvitationDetails:inviteId completion:^(InvitationCodeDetails *details, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (!error) {
            [self openMenuItem:MenuAlerts];
            GroupSettingsViewController *vc = [[GroupSettingsViewController alloc] initWithGroup:details.group invitationCode:inviteId];
            [self.visibleViewController pushViewController:vc animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)showPrediction:(NSInteger)predictionId {
    [[LoadingView sharedInstance] show];
    if ([self.visibleViewController.topViewController isKindOfClass:PredictionDetailsViewController.class])
        return;
    [[WebApi sharedInstance] getPrediction:predictionId completion:^(Prediction *prediction, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (error)
            return;
        [self openMenuItem:MenuAlerts];
        PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
        [self.visibleViewController pushViewController:vc animated:YES];
    }];
}

- (void)activeGroupChanged:(NSNotification *)notification {
    Group *newGroup = [notification.userInfo objectForKey:ActiveGroupNotificationKey];
    if (newGroup)
        self.activeGroup = newGroup;
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.pingTimer invalidate];
    self.pingTimer = nil;    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];


    self.scrollView.bezelWidth = SideNavBezelWidth;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 4, self.scrollView.frame.size.height);

    for (int i = 0; i < 1; i++) {
        UINavigationController *vc = [self navigationControllerForMenuItem:i];
        CGRect frame = vc.view.frame;
        frame.size = self.scrollView.frame.size;
        frame.origin.x = i * frame.size.width;
        frame.origin.y = 0;
        vc.view.frame = frame;
        [self.scrollView addSubview:vc.view];
    }
    
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(serverPing) userInfo:nil repeats:YES];
}

- (void)addExtraViewControllers {
    for (int i = 1; i < MenuItemsCount; i++) {
        UINavigationController *vc = [self navigationControllerForMenuItem:i];
        CGRect frame = vc.view.frame;
        frame.size = self.scrollView.frame.size;
        frame.origin.x = i * frame.size.width;
        frame.origin.y = 0;
        vc.view.frame = frame;
        [self.scrollView addSubview:vc.view];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([UserManager sharedInstance].user) {
        [self addExtraViewControllers];
    }
    
    if (self.appeared)
        return;
    
    self.appeared = YES;
    
    
    if(![UserManager sharedInstance].user.hasAvatar && [UserManager sharedInstance].user)
        [self showSelectPictureViewController];
    else {
        [self openMenuItem:MenuHome];
        if (self.launchUrl) {
            [self handleOpenUrl:self.launchUrl];
        }
        [self handlePushInfo:self.pushInfo];
    }
    
    if (![UserManager sharedInstance].user) {
        WelcomeViewController *vc = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:[NSBundle mainBundle]];
        self.welcomeNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        
        CGRect frame = self.welcomeNavigationController.view.frame;
        frame.origin.y = self.view.frame.size.height;
        self.welcomeNavigationController.view.frame = frame;
        frame.origin.y = 0;
        
        [self.view.window addSubview:self.welcomeNavigationController.view];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.welcomeNavigationController.view.frame = frame;
        }];
    } else {
        if (![UserManager sharedInstance].user.phone || [[UserManager sharedInstance].user.phone isEqualToString:@""]) {
            
            
            NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PhoneNumberNagCount"] integerValue];
            
            if (count >= 2)
                return;
            
            
            NSString *cancelButtonTitle;
            
            if (count == 0)
                cancelButtonTitle = @"No Thanks";
            else
                cancelButtonTitle = @"Never";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone Number" message:@"Make it easier for friends to find you on Knoda by entering your phone number. You can always add or remove your number in Profile Settings." delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:@"Save", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            [alert show];
            
        }
    }
}

- (void)serverPing {
    [self updateAlerts];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeAllObservations];
}

- (void)openMenuItem:(MenuItem)menuItem {
    UINavigationController *previousNavigationController = self.visibleViewController;
    self.activeMenuItem = menuItem;
    self.visibleViewController = [self navigationControllerForMenuItem:self.activeMenuItem];
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *button = [self.buttons objectAtIndex:i];
        UIImage *image;
        if (i != self.activeMenuItem && i != MenuAlerts)
            image = [UIImage imageNamed:self.buttonNames[i]];
        else if (i == MenuAlerts && i != self.activeMenuItem) {
            image = self.unseenAlertsCount == 0 ? [UIImage imageNamed:@"NavActivity"] : [UIImage imageNamed:@"NavActivityNotifications"];
        } else {
            NSString *name = [NSString stringWithFormat:@"%@Active", self.buttonNames[i]];
            image = [UIImage imageNamed:name];
        }
        [button setImage:image forState:UIControlStateNormal];
    }
    
    [self.scrollView setContentOffset:CGPointMake(self.activeMenuItem * self.scrollView.frame.size.width, 0) animated:YES];
    
    UIViewController<NavigationViewControllerDelegate> *vc = (UIViewController<NavigationViewControllerDelegate> *)self.visibleViewController.visibleViewController;
    
    if ([vc respondsToSelector:@selector(viewDidAppearInNavigationViewController:)])
        [vc viewDidAppearInNavigationViewController:self];
    
    vc = (UIViewController<NavigationViewControllerDelegate> *)previousNavigationController.visibleViewController;
    
    if ([vc respondsToSelector:@selector(viewDidDisappearInNavigationViewController:)])
        [vc viewDidDisappearInNavigationViewController:self];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [previousNavigationController popToRootViewControllerAnimated:NO];
    });
    
    if (previousNavigationController == self.visibleViewController) {
        if ([self.visibleViewController.visibleViewController respondsToSelector:@selector(tableView)])
            [[(id)self.visibleViewController.visibleViewController tableView] setContentOffset:CGPointZero animated:YES];
    }
    
    if ([previousNavigationController.visibleViewController respondsToSelector:@selector(tableView)])
        [[(id)previousNavigationController.visibleViewController tableView] setScrollsToTop:NO];
    
    if ([self.visibleViewController.visibleViewController respondsToSelector:@selector(tableView)])
        [[(id)self.visibleViewController.visibleViewController tableView] setScrollsToTop:YES];
    
    if (menuItem == MenuAlerts)
        _unseenAlertsCount = 0;

}

- (IBAction)tabBarButtonPressed:(id)sender {
    if (![self.buttons containsObject:sender] || !self.tabBarEnabled)
        return;
    
    [self openMenuItem:[self.buttons indexOfObject:sender]];
}

- (UINavigationController *)navigationControllerForMenuItem:(MenuItem)menuItem {
    UINavigationController *navigationController = [self.vcCache objectForKey:@(menuItem)];
    UIViewController *viewController;
    if (!navigationController) {
        switch (menuItem) {
            case MenuHome:
                viewController = [[NewHomeViewController alloc] initWithNibName:@"NewHomeViewController" bundle:[NSBundle mainBundle]];
                break;
            case MenuAlerts:
                viewController = [[NewActivityViewController alloc] init];
                break;
            case MenuProfile:
                viewController = [[MeViewController alloc] initWithNibName:@"MeViewController" bundle:[NSBundle mainBundle]];
                break;
            case MenuGroups:
                viewController = [[CGViewController alloc] init];
                break;
            default:
                viewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
                break;
        }
    } else
        return navigationController;
    
    if (menuItem != MenuGroups)
        self.activeGroup = nil;
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.vcCache setObject:navigationController forKey:@(menuItem)];

    return navigationController;
}

- (void)updateAlerts {
    [[WebApi sharedInstance] getUnseenActivity:^(NSArray *alerts, NSError *error) {
        if (error)
            return;
        
        if (!(self.unseenAlertsCount > 0 && alerts.count == 0))
            _unseenAlertsCount = alerts.count;
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:alerts.count];
        
        if (self.activeMenuItem == MenuAlerts)
            return;
        
        UIButton *activityButton = self.buttons[MenuAlerts];
        UIImage *image;
        
        if (self.unseenAlertsCount == 0)
            image = [UIImage imageNamed:self.buttonNames[MenuAlerts]];
        else
            image = [UIImage imageNamed:@"NavActivityNotifications"];
        [activityButton setImage:image forState:UIControlStateNormal];
    }];
}
- (void)setUnseenAlertsCount:(NSInteger)unseenAlertsCount {
    [self updateAlerts];
}

- (AppDelegate *)appDelegate {
    return [UIApplication sharedApplication].delegate;
}
#pragma mark SelectPictureDelegate

- (void)showSelectPictureViewController {
    self.selectVc = [[SelectPictureViewController alloc] initWithBaseDefaultImageName:@"avatar"];
    self.selectVc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.selectVc];
    
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)hideViewController:(SelectPictureViewController *)vc {
    [[LoadingView sharedInstance] hide];
    [self openMenuItem:MenuHome];
}


- (IBAction)presentAddPredictionViewController {
    AddPredictionViewController *vc = [[AddPredictionViewController alloc] initWithActiveGroup:self.activeGroup];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PredictWalkthroughCompleteNotificationName object:nil];
}

- (void)addPredictionViewController:(AddPredictionViewController *)viewController didCreatePrediction:(Prediction *)prediction {
    [[NSNotificationCenter defaultCenter] postNotificationName:NewObjectNotification object:nil userInfo:@{NewPredictionNotificationKey: prediction}];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)dealloc {
    [self removeAllObservations];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    [self openMenuItem:page];
}

- (void)processImage:(NSNotification *)notification {
    UIImage *image = [self.view captureView];
    image = [image applyExtraLightEffect];
    self.blurImageView = [[UIImageView alloc] initWithImage:image];
    self.blurImageView.alpha = 0;
    
    [self.view insertSubview:self.blurImageView belowSubview:self.welcomeNavigationController.view];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.blurImageView.alpha = 1.0;
    }];
}

- (void)handleLogin {
    [self addExtraViewControllers];
    self.tabBarEnabled = YES;
    CGRect frame = self.welcomeNavigationController.view.frame;
    
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.welcomeNavigationController.view.frame = frame;
        self.blurImageView.frame = frame;
        [self.welcomeNavigationController.view removeFromSuperview];
        [self.blurImageView removeFromSuperview];
        self.blurImageView = nil;
        self.welcomeNavigationController = nil;
    }];
    
    
    if (![UserManager sharedInstance].user.phone || [[UserManager sharedInstance].user.phone isEqualToString:@""]) {
        
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PhoneNumberNagCount"] integerValue];
        
       if (count >= 2)
           return;
        
        
        NSString *cancelButtonTitle;
        
        if (count == 0)
            cancelButtonTitle = @"No Thanks";
        else
            cancelButtonTitle = @"Never";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone Number" message:@"Make it easier for friends to find you on Knoda by entering your phone number. You can always add or remove your number in Profile Settings." delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:@"Save", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [alert show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PhoneNumberNagCount"] integerValue];
        count++;
        [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:@"PhoneNumberNagCount"];
    } else {
        NSString *phone = [[alertView textFieldAtIndex:0] text];
        [self savePhone:phone];
    }
}
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if ([alertView textFieldAtIndex:0].text.length == 0)
        return NO;
    return YES;
}

- (void)savePhone:(NSString *)phone {
    User *user = [[UserManager sharedInstance].user copy];
    user.phone = phone;
    
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

- (void)getStarted {
    SocialInvitationsViewController *vc = [[SocialInvitationsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    });
}
@end
