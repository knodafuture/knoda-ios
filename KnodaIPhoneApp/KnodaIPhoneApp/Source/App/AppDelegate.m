//
//  AppDelegate.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpRequest.h"
#import "LoadingView.h"
#import "KeychainItemWrapper.h"
#import "WelcomeViewController.h"
#import "NavigationViewController.h"
#import "UserManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UserManager.h"


static NSString *kFlurryKey = @"QTDYWKWSJXK9YNDHKN5Z";
static NSString *kTestFlightKey = @"9bbf4e38-5f9a-427f-b4ca-23625ccee3a0";
static NSString *kDeviceTokenKey = @"DeviceToken";
static NSString *kDeviceTokenIdKey = @"DeviceTokenID";

NSString *FirstLaunchKey = @"FirstLaunch";
NSString *NewObjectNotification = @"NewPredictionNotification";
NSString *NewPredictionNotificationKey = @"NewPredictionNotificationKey";
NSString *NewGroupNotificationKey = @"NEWGROUPNOTIFICATIONKEY";

@interface AppDelegate() <UIAlertViewDelegate>
@property (strong, nonatomic) NSDictionary *pushInfo;
@property (strong, nonatomic) NavigationViewController *navigationViewController;
@property (strong, nonatomic) NSURL *launchUrl;
@property (assign, nonatomic) BOOL notificationAlertShown;
@property (strong, nonatomic) UIImageView *splashImageView;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self window].backgroundColor = [UIColor blackColor];

#ifdef TESTFLIGHT
    //[TestFlight takeOff:kTestFlightKey];
#else
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
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:HttpForbiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deprecatedApi) name: DeprecatedAPI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:UserLoggedOutNotificationName object:nil];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    [self showSplash];
    [self.window makeKeyAndVisible];
    
    [[UserManager sharedInstance] authenticateSavedUser:^(User *user, NSError *error) {
        [self showHomeScreen];
        [self.splashImageView removeFromSuperview];
    }];
    
    return YES;
}

- (void)showSplash {
    NSString *launchImage;
    if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
         ([UIScreen mainScreen].bounds.size.height > 480.0f)) {
        launchImage = @"LaunchImage-700-568h";
    } else {
        launchImage = @"LaunchImage-700";
    }
    UIImage *bgImage = [UIImage imageNamed:launchImage];
    self.splashImageView = [[UIImageView alloc] initWithImage:bgImage];
    [self.window addSubview:self.splashImageView];
}

- (void)logout {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    [self showSplash];
    [self.window makeKeyAndVisible];
    
    [self showHomeScreen];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.splashImageView removeFromSuperview];

    });
    
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
    
    if (application.applicationState == UIApplicationStateActive && !self.notificationAlertShown) {
        if (alertString.length != 0) {
            self.notificationAlertShown = YES;
            self.pushInfo = userInfo;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:alertString delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Show", @""), nil];
            [alertView show];
        }
    } else {
        [self.navigationViewController handlePushInfo:userInfo];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.notificationAlertShown = NO;
    if (buttonIndex != alertView.cancelButtonIndex)
        [self.navigationViewController handlePushInfo:self.pushInfo];
}

- (void)showHomeScreen {
    self.navigationViewController = [[NavigationViewController alloc] initWithPushInfo:self.pushInfo];
    
    if (self.launchUrl)
        self.navigationViewController.launchUrl = self.launchUrl;
    
    self.window.rootViewController = self.navigationViewController;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //TODO deprecation
//    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//    if([title isEqualToString:@"Update"])
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://itunes.apple.com/us/app/knoda/id764642995?mt=8"]];
//    }
//    if ([title isEqualToString:@"Retry"]) {
//        [self showWelcomeScreenAnimated:YES];
//    }
}

- (void)deprecatedApi {
    [[LoadingView sharedInstance] reset];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Version No Longer Accessible." message:@"This version of the app is no longer supported, please update now to the current verison to continue enjoying Knoda." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
    [[UserManager sharedInstance] clearSavedCredentials];
    //[self showWelcomeScreenAnimated:YES];
    [alert show];
}


@end
