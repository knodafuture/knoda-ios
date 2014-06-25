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
#import "UserManager.h"
#import <FacebookSDK/FacebookSDK.h>

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
@property (strong, nonatomic) NSDictionary *pushInfo;
@property (strong, nonatomic) NavigationViewController *navigationViewController;
@property (strong, nonatomic) NSURL *launchUrl;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self window].backgroundColor = [UIColor blackColor];

#ifdef TESTFLIGHT
    //[TestFlight takeOff:kTestFlightKey];
#else
   [Tapjoy requestTapjoyConnect:@"e22aa80e-473f-4015-88b6-c8fa717ca9bd" secretKey:@"c6hlD8xuRyo3acWyfUl8" options:@{TJC_OPTION_ENABLE_LOGGING:@(YES)}];
    [Flurry setCrashReportingEnabled: YES];
    [Flurry startSession: kFlurryKey];
#endif
    
    if (launchOptions != nil) {
        // Launched from push notification
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
            NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            self.pushInfo = notification;

        } else if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
            self.launchUrl = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        }
    }
    
    UIColor *navBackgroundColor = [UIColor colorFromHex:@"77BC1F"];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [UINavigationBar setCustomAppearance];
    [UIApplication sharedApplication].delegate.window.backgroundColor = navBackgroundColor;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:HttpForbiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deprecatedApi) name: DeprecatedAPI object:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    [self.window makeKeyAndVisible];
    
    [self showWelcomeScreenAnimated:NO];
    
    NSLog(@"launched'");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBadge:) name:BadgeNotification object:nil];
    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL handledByFB = [FBAppCall handleOpenURL:url
                                                  sourceApplication:sourceApplication
                                                    fallbackHandler:^(FBAppCall *call) {
                                                        
                                                        // Retrieve the link associated with the post
                                                        NSURL *targetURL = [[call appLinkData] targetURL];
                                                        
                                                        self.launchUrl = targetURL;
                                                    }
                                            ];
    
    if (!handledByFB) {
        self.launchUrl = url;
        return YES;
    } else
        return handledByFB;
    
    return NO;
}

- (void)setLaunchUrl:(NSURL *)launchUrl {
    if (self.navigationViewController)
        [self.navigationViewController handleOpenUrl:launchUrl];
    _launchUrl = launchUrl;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];

    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
    
    [FBSettings setDefaultAppID:@"455514421245892"];
    [FBAppEvents activateApp];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *tokenString = [[[deviceToken description]
                              stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                             stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kDeviceTokenKey];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSString *alertString = [[userInfo objectForKey: @"aps"] objectForKey: @"alert"];
    
    if (application.applicationState == UIApplicationStateActive) {
        if (alertString.length != 0) {
            self.pushInfo = userInfo;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:alertString delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Show", @""), nil];
            [alertView show];
        }
    } else {
        [self.navigationViewController handlePushInfo:userInfo];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex)
        [self.navigationViewController handlePushInfo:self.pushInfo];
}

- (void)newBadge:(NSNotification *)notifcation {
    NSArray *badges = notifcation.userInfo[BadgeNotificationKey];
    
    Badge *badge = [badges firstObject];
    
    [NewBadgeView showWithBadge:[UIImage imageNamed:badge.name] animated:YES];
    
#ifndef TESTFLIGHT
    [self sendshittotapjoyifnecessarybadcodehere:badge.name];
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
    self.navigationViewController = [[NavigationViewController alloc] initWithPushInfo:self.pushInfo];
    
    if (self.launchUrl)
        self.navigationViewController.launchUrl = self.launchUrl;
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Update"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://itunes.apple.com/us/app/knoda/id764642995?mt=8"]];
    }
}

- (void)deprecatedApi {
    [[LoadingView sharedInstance] reset];
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Version No Longer Accessible." message:@"This version of the app is no longer supported, please update now to the current verison to continue enjoying Knoda." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
    [[UserManager sharedInstance] clearSavedCredentials];
    [self showWelcomeScreenAnimated:YES];
    [alert show];
    
    
}



@end
