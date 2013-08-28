//
//  AppDelegate.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"
#import "KeychainItemWrapper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User* user;

@property (strong, nonatomic) KeychainItemWrapper *passwordItem;

@property (copy, nonatomic) NSString* deviceToken;

- (void) savePassword: (NSString*) password;
- (void) removePassword;

- (NSDictionary*) credentials;

- (void) sendToken;

- (void)logout;

@end
