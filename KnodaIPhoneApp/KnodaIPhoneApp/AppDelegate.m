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

#import "SendDeviceTokenWebRequest.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIImage* navBackgroundImage = [UIImage imageNamed: @"headerBar"];
    [[UINavigationBar appearance] setBackgroundImage: navBackgroundImage forBarMetrics: UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], UITextAttributeTextColor,
                                                           [UIColor blackColor], UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset: UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset,
                                                           [UIFont fontWithName: @"Krona One" size: 15], UITextAttributeFont, nil]];
    
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor colorWithRed:99/255.0 green:185/255.0 blue:0 alpha:1];
    
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier: @"Password" accessGroup: @"F489V4H5F6.com.Knoda.KnodaIPhoneApp"];
	self.passwordItem = wrapper;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewBadgeNotification:) name:NewBadgeNotification object:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
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
        [request executeWithCompletionBlock: ^{}];
    }
}


- (void)application: (UIApplication*) app didRegisterForRemoteNotificationsWithDeviceToken: (NSData*) deviceToken
{
    NSLog(@"Registered push notifications token: %@", [deviceToken description]);
    
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
    NSLog(@"Error in registration. Error: %@", err);
    self.deviceToken = nil;
}


- (void) application: (UIApplication*) application didReceiveRemoteNotification: (NSDictionary*) userInfo
{
    NSLog(@"Push notification arrived: %@", userInfo);
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

- (void)handleNewBadgeNotification:(NSNotification *)notification {
    NSArray *images = [notification userInfo][kNewBadgeImages];
    [NewBadgeView showWithBadge:[images lastObject] animated:YES];
}

@end
