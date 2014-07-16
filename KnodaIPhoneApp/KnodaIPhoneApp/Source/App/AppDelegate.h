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

UIKIT_EXTERN NSString *NewObjectNotification;
UIKIT_EXTERN NSString *NewPredictionNotificationKey;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)login;
- (void)logout;

@end
