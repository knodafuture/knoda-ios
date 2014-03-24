//
//  AppDelegate.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpRequest.h"
#import "NewBadgeView.h"
#import "LoadingView.h"
#import "KeychainItemWrapper.h"
#import "WelcomeViewController.h"
#import "NavigationViewController.h"

#ifdef TESTFLIGHT
#import "TestFlight.h"
#else
#import <Tapjoy/Tapjoy.h>
#endif

static NSString *kFlurryKey = @"QTDYWKWSJXK9YNDHKN5Z";
static NSString *kTestFlightKey = @"9bbf4e38-5f9a-427f-b4ca-23625ccee3a0";
static NSString *kDeviceTokenKey = @"DeviceToken";
static NSString *kDeviceTokenIdKey = @"DeviceTokenID";

NSString *FirstLaunchKey = @"FirstLaunch";
NSString *BadgeNotification = @"BadgeNotification";
NSString *BadgeNotificationKey = @"BadgeNotificationKey";
NSString *NewObjectNotification = @"NewPredictionNotification";
NSString *NewPredictionNotificationKey = @"NewPredictionNotificationKey";

@interface AppDelegate() <UIAlertViewDelegate>
@property (assign, nonatomic) BOOL launchedFromPush;
@property (strong, nonatomic) NavigationViewController *navigationViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef TESTFLIGHT
    //[TestFlight takeOff:kTestFlightKey];
#else
   [Tapjoy requestTapjoyConnect:@"e22aa80e-473f-4015-88b6-c8fa717ca9bd" secretKey:@"c6hlD8xuRyo3acWyfUl8" options:@{TJC_OPTION_ENABLE_LOGGING:@(YES)}];
    [Flurry setCrashReportingEnabled: YES];
    [Flurry startSession: kFlurryKey];
#endif
    
    if (launchOptions != nil) {
        // Launched from push notification
        NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        self.launchedFromPush = notification != nil;
    }
    
    UIColor *navBackgroundColor = [UIColor colorFromHex:@"77BC1F"];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [UINavigationBar setCustomAppearance];
    [UIApplication sharedApplication].delegate.window.backgroundColor = navBackgroundColor;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:HttpForbiddenNotification object:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    [self.window makeKeyAndVisible];
    
    [self showWelcomeScreenAnimated:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBadge:) name:BadgeNotification object:nil];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *tokenString = [[[deviceToken description]
                              stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                             stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kDeviceTokenKey];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString *alertString = [[userInfo objectForKey: @"aps"] objectForKey: @"alert"];
    
    if (alertString.length != 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:alertString delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Show", @""), nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex)
        [self.navigationViewController openMenuItem:MenuAlerts];
}

- (void)newBadge:(NSNotification *)notifcation {
    NSArray *badges = notifcation.userInfo[BadgeNotificationKey];
    
    Badge *badge = [badges firstObject];
    
    [NewBadgeView showWithBadge:[UIImage imageNamed:badge.name] animated:YES];
#ifndef TESTFLIGHT

    [self sendsendshittotapjoyifnecessarybadcodehere:badge.name];
#endif

}


#ifndef TESTFLIGHT

- (void)sendshittotapjoyifnecessarybadcodehere:(NSString *)badgeName {
    
    if ([badgeName isEqualToString:@"1_prediction"]) {
        [Tapjoy actionComplete:TJC_CREATE_FIRST_PREDICTION];
    }
    if ([badgeName isEqualToString:@"1_challenge"])
        [Tapjoy actionComplete:TJC_CREATE_FIRST_CHALLENGE];
}
#endif



- (void)showWelcomeScreenAnimated:(BOOL)animated {
    WelcomeViewController *welcome = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:[NSBundle mainBundle]];
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:welcome];
    
    if (!animated) {
        self.window.rootViewController = vc;
        return;
    }
    
    [UIView transitionFromView:self.window.rootViewController.view toView:vc.view duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
         self.window.rootViewController = vc;
                           self.navigationViewController = nil;
     }];
}

- (void)showHomeScreen:(BOOL)animated {
    
    MenuItem startingMenuItem;
    if (self.launchedFromPush) {
        startingMenuItem = MenuAlerts;
        self.launchedFromPush = NO;
    } else
        startingMenuItem = MenuHome;
    
    
    self.navigationViewController = [[NavigationViewController alloc] initWithFirstMenuItem:startingMenuItem];
    
    if (!animated) {
        self.window.rootViewController = self.navigationViewController;
        return;
    }
    
    [UIView transitionFromView:self.window.rootViewController.view toView:self.navigationViewController.view duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        self.window.rootViewController = self.navigationViewController;
       [self.navigationViewController hackAnimationFinished];
    }];
}

- (void)login {
    [[LoadingView sharedInstance] reset];
    [self showHomeScreen:YES];
}

- (void)logout {
    
    [[LoadingView sharedInstance] reset];
    
    [self showWelcomeScreenAnimated:YES];
}

@end
