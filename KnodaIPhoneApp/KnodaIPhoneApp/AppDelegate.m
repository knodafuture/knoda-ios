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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
/*    LoginWebRequest* loginRequest = [[LoginWebRequest alloc] initWithUsername: @"" password: @""];
    [loginRequest executeWithCompletionBlock: ^
    {
        self.user = loginRequest.user;
        
        AddPredictionRequest* addPredictionRequest = [[AddPredictionRequest alloc] initWithBody: @"" expirationDay: 17 expirationMonth: 11 expirationYear: 2015];
        [addPredictionRequest executeWithCompletionBlock: ^
        {
            PredictionsWebRequest* predictionsRequest = [[PredictionsWebRequest alloc] init];
            [predictionsRequest executeWithCompletionBlock: ^{}];
        }];
    }];*/
    
    //SignUpRequest* signUpRequest = [[SignUpRequest alloc] initWithUsername: @"" email: @"" password: @""];
    //[signUpRequest executeWithCompletionBlock: ^{}];
    
    UIImage* navBackgroundImage = [UIImage imageNamed: @"headerBar"];
    [[UINavigationBar appearance] setBackgroundImage: navBackgroundImage forBarMetrics: UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], UITextAttributeTextColor,
                                                           [UIColor blackColor], UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset: UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset,
                                                           [UIFont fontWithName: @"Krona One" size: 13], UITextAttributeFont, nil]];
    
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
    
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

@end
