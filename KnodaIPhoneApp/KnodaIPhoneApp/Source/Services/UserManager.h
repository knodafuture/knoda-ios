//
//  UserManager.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User+Utils.h"
#import "LoginRequest.h"    
#import "SignupRequest.h"   
#import "LoginResponse.h"
#import "SocialAccount.h"

extern NSString *UserChangedNotificationName;
extern NSString *ChangedUserKey;
@interface UserManager : NSObject

@property (readonly, nonatomic) User *user;
@property (readonly, nonatomic) NSArray *groups;

- (void)authenticateSavedUser:(void(^)(User *user, NSError *error))completionHandler;
- (void)refreshUser:(void(^)(User *user, NSError *error))completionHandler;
- (void)updateUser:(User *)user completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)login:(LoginRequest *)request completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)signup:(SignupRequest *)request completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)signout:(void(^)(NSError *error))completionHandler;
- (void)uploadProfileImage:(UIImage *)profileImage completion:(void(^)(User *user, NSError *error))completionHandler;

- (void)socialSignIn:(SocialAccount *)request completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)addSocialAccount:(SocialAccount *)account completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)deleteSocialAccount:(SocialAccount *)account completion:(void(^)(User *user, NSError *error))completionHandler;

+ (UserManager *)sharedInstance;

@end
