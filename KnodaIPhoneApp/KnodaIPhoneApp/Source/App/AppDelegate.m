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

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef TESTFLIGHT
    [TestFlight takeOff:kTestFlightKey];
#else
    [Tapjoy requestTapjoyConnect:@"e22aa80e-473f-4015-88b6-c8fa717ca9bd" secretKey:@"c6hlD8xuRyo3acWyfUl8" options:@{TJC_OPTION_ENABLE_LOGGING:@(YES)}];
    [Flurry setCrashReportingEnabled: YES];
    [Flurry startSession: kFlurryKey];
#endif
    
    
    UIColor *navBackgroundColor = [UIColor colorFromHex:@"77BC1F"];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [UINavigationBar setCustomAppearance];
    [UIApplication sharedApplication].delegate.window.backgroundColor = navBackgroundColor;
    
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier: @"Password" accessGroup:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:HttpForbiddenNotification object:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorFromHex:@"77bc1f"];
    [self.window makeKeyAndVisible];
    
    [self showWelcomeScreenAnimated:NO];
    
    [self observeProperty:@keypath(self.currentUser) withBlock:^(__weak id self, User* old, User* new) {
        if (!new)
            return;
        [[NSUserDefaults standardUserDefaults] setObject:new.name forKey: @"User"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBadge:) name:BadgeNotification object:nil];
    
    return YES;
}

- (void)submitDeviceToken {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceTokenKey];
    
    if (!deviceToken)
        return;
    
    [[WebApi sharedInstance] sendToken:deviceToken completion:^(NSString *tokenId, NSError *error) {
        if (!error)
            [[NSUserDefaults standardUserDefaults] setObject:tokenId forKey:kDeviceTokenIdKey];
    }];
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
        
        //TODO REDO SHOW ALERTS
    }
}

- (void)newBadge:(NSNotification *)notifcation {
    NSArray *badges = notifcation.userInfo[BadgeNotificationKey];
    
    Badge *badge = [badges firstObject];
    
    [NewBadgeView showWithBadge:[UIImage imageNamed:badge.name] animated:YES];
}

- (void)clearSavedCredentials {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"User"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LoginResponseKey];
    [self.keychain resetKeychainItem];
}

- (void)removeToken {
    NSString *deviceTokenId = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceTokenIdKey];
    
    if (!deviceTokenId)
        return;
    
    
    [[WebApi sharedInstance] deleteToken:deviceTokenId completion:^(NSError *error) {}];
}

- (void)logout {
    [[WebApi sharedInstance] signoutCompletion:^(NSError *error) {}];
    
    self.currentUser = nil;
    
    [self clearSavedCredentials];

    [[LoadingView sharedInstance] reset];
    
    [self showWelcomeScreenAnimated:YES];
}


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
     }];
}

- (void)showHomeScreen:(BOOL)animated {
    
    NavigationViewController *vc = [[NavigationViewController alloc] initWithNibName:@"NavigationViewController" bundle:[NSBundle mainBundle]];

    if (!animated) {
        self.window.rootViewController = vc;
        return;
    }
    
    [UIView transitionFromView:self.window.rootViewController.view toView:vc.view duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        self.window.rootViewController = vc;
       [vc hackAnimationFinished];
    }];
}

- (void)saveRequest:(LoginRequest *)request andResponse:(LoginResponse *)response {
    [[NSUserDefaults standardUserDefaults] setObject:request.username forKey: @"User"];
    [[NSUserDefaults standardUserDefaults] setObject:response.token forKey:LoginResponseKey];
    [self.keychain setObject:request.password forKey:((__bridge id)kSecValueData)];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)doLogin:(LoginRequest *)request withResponse:(LoginResponse *)response {

    [self saveRequest:request andResponse:response];

    [[WebApi sharedInstance] getCurrentUser:^(User *user, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (error) {
            [self logout];
            [self showWelcomeScreenAnimated:YES];
        } else {
            [self setValue:user forKey:@"currentUser"];
            [self submitDeviceToken];
            [self showHomeScreen:YES];
        }
    }];
}

- (void)reauthorize:(LoginRequest *)request withResponse:(LoginResponse *)response {
    [self saveRequest:request andResponse:response];
    
    [[WebApi sharedInstance] getCurrentUser:^(User *user, NSError *error) {
        if (error) {
            [self logout];
            [self showWelcomeScreenAnimated:YES];
        } else {
            [self setValue:user forKey:@"currentUser"];
            [self submitDeviceToken];
        }
    }];
}

- (LoginRequest *)loginRequestForSavedUser {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey: @"User"];
    NSString *password = [self.keychain objectForKey: ((__bridge id)kSecValueData)];
    
    if (!username || !password)
        return nil;
    
    LoginRequest *request = [[LoginRequest alloc] init];
    request.username = username;
    request.password = password;
    
    return request;
}

@end
