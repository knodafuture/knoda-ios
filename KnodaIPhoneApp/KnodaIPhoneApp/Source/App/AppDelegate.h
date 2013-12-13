//
//  AppDelegate.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebApi.h"
@class User;
@class KeychainItemWrapper;

extern NSString *FirstLaunchKey;
UIKIT_EXTERN NSString *BadgeNotification;
UIKIT_EXTERN NSString *BadgeNotificationKey;

UIKIT_EXTERN NSString *NewObjectNotification;
UIKIT_EXTERN NSString *NewPredictionNotificationKey;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) KeychainItemWrapper *keychain;
@property (strong, nonatomic) User *currentUser;


- (void)doLogin:(LoginRequest *)request withResponse:(LoginResponse *)response;
- (void)reauthorize:(LoginRequest *)request withResponse:(LoginResponse *)response;
- (LoginRequest *)loginRequestForSavedUser;
- (void)logout;
- (void)presentAddPredictionViewController;

@end
