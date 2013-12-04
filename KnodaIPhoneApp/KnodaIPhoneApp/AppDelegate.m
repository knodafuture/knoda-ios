//
//  AppDelegate.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AppDelegate.h"

//! TODO: remove test headers
#import "PredictionsWebRequest.h"
#import "LoginWebRequest.h"
#import "SignUpRequest.h"
#import "AddPredictionRequest.h"
#import "BadgesWebRequest.h"
#import "NewBadgeView.h"
#import "SignOutWebRequest.h"
#import "ImageCache.h"
#import "LoadingView.h"
#import "AddPredictionViewController.h"
#import "SendDeviceTokenWebRequest.h"
#import "RemoveTokenWebRequest.h"



#ifdef TESTFLIGHT
#import "TestFlight.h"
#endif

static NSString* const kFlurryKey = @"QTDYWKWSJXK9YNDHKN5Z";
static NSString* const kTestFlightKey = @"9bbf4e38-5f9a-427f-b4ca-23625ccee3a0";
NSString* const kAlertNotification = @"AlertNotification";

@interface AppDelegate() <UIAlertViewDelegate, AddPredictionViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
#ifdef TESTFLIGHT
    [TestFlight takeOff:kTestFlightKey];
#else
    [Flurry setCrashReportingEnabled: YES];
#endif
    
    
    [Flurry startSession: kFlurryKey];
    
    UIColor *navBackgroundColor = [UIColor colorFromHex:@"77BC1F"];
    
    if (SYSTEM_VERSION_GREATER_THAN(@"7.0")) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar"] forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar6"] forBarMetrics:UIBarMetricsDefault];

        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:4.0 forBarMetrics:UIBarMetricsDefault];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    }

    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorFromHex:@"235C37"], UITextAttributeTextColor,
                                                           [UIFont fontWithName: @"Krona One" size: 15], UITextAttributeFont,
                                                           [UIColor clearColor], UITextAttributeTextShadowColor ,nil]];
    
    [UIApplication sharedApplication].delegate.window.backgroundColor = navBackgroundColor;
    
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier: @"Password" accessGroup: @"F489V4H5F6.com.Knoda.KnodaIPhoneApp"];
	self.passwordItem = wrapper;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewBadgeNotification:) name:NewBadgeNotification object:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    if ([launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey] != nil)
    {
        self.notificationReceived = YES;
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) sendToken
{
    if (self.deviceToken != nil)
    {
        SendDeviceTokenWebRequest* request = [[SendDeviceTokenWebRequest alloc] initWithToken: self.deviceToken];
        [request executeWithCompletionBlock: ^
        {
            if (request.errorCode == 0)
            {
                self.deviceTokenID = request.tokenID;
            }
        }];
    }
}


- (void)application: (UIApplication*) app didRegisterForRemoteNotificationsWithDeviceToken: (NSData*) deviceToken
{
    
    self.deviceToken = [[[deviceToken description]
                                stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (self.user != nil)
    {
        [self sendToken];
    }
}


- (void) application: (UIApplication*) app didFailToRegisterForRemoteNotificationsWithError: (NSError*) err
{
    self.deviceToken = nil;
}


- (void) application: (UIApplication*) application didReceiveRemoteNotification: (NSDictionary*) userInfo
{
    NSString* alertString = [[userInfo objectForKey: @"aps"] objectForKey: @"alert"];
    
    if (alertString.length != 0)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"" message: alertString delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel", @"") otherButtonTitles: NSLocalizedString(@"Show", @""), nil];
        [alertView show];
    }
}


- (void) alertView:(UIAlertView*) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kAlertNotification object: nil];
    }
}


- (void) savePassword: (NSString*) password
{
    if (self.user.name.length != 0)
    {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject: self.user.name forKey: @"User"];
        
        [self.passwordItem setObject: password forKey: ((__bridge id)kSecValueData)];
    }
}


- (void) removePassword
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"User"];
    [self.passwordItem resetKeychainItem];
}


- (NSDictionary*) credentials
{
    NSDictionary* result = nil;
    
    NSString* userName = [[NSUserDefaults standardUserDefaults] objectForKey: @"User"];
    
    if (userName.length != 0)
    {
        NSString* password = [self.passwordItem objectForKey: ((__bridge id)kSecValueData)];
        
        if (password.length != 0)
        {
            result = @{@"User": userName, @"Password": password};
        }
    }
    
    return result;
}

- (void)logout {
    DLog(@"performing logout");
    
    if (self.deviceTokenID != nil)
    {
        RemoveTokenWebRequest* request = [[RemoveTokenWebRequest alloc] initWithTokenID: self.deviceTokenID];
        [request executeWithCompletionBlock: nil];
    }
    
    SignOutWebRequest *signOutWebRequest = [SignOutWebRequest new];
    [signOutWebRequest executeWithCompletionBlock:nil];
    
    self.user = nil;
    
    [self removePassword];
    [[ImageCache instance] clear];
    
    UINavigationController *nc = (UINavigationController *)self.window.rootViewController;
    [nc dismissViewControllerAnimated:NO completion:nil];
    [nc popToRootViewControllerAnimated:NO];
    
    [[LoadingView sharedInstance] reset];
}

- (void)handleNewBadgeNotification:(NSNotification *)notification {
    NSArray *images = [notification userInfo][kNewBadgeImages];
    [NewBadgeView showWithBadge:[images lastObject] animated:YES];
}


- (void)presentAddPredictionViewController {
    AddPredictionViewController *vc = [[AddPredictionViewController alloc] initWithNibName:@"AddPredictionViewController" bundle:[NSBundle mainBundle]];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
}
- (void)predictionWasMadeInController:(AddPredictionViewController *)vc {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
