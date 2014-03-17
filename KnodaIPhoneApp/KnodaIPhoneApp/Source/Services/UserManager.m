//
//  UserManager.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/17/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "UserManager.h"
#import "WebApi.h"
#import "KeychainItemWrapper.h"


static NSString *kDeviceTokenKey = @"DeviceToken";
static NSString *kDeviceTokenIdKey = @"DeviceTokenID";
NSString *UserChangedNotificationName = @"USERCHANGED";
NSString *ChangedUserKey = @"CHANGEDUSER";
static UserManager *sharedSingleton;

@interface UserManager ()
@property (strong, nonatomic) KeychainItemWrapper *keychain;
@end


@implementation UserManager

- (id)init {
    self = [super init];
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier: @"Password" accessGroup:nil];
    return self;
}

+ (UserManager *)sharedInstance {
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
    });
    
    return sharedSingleton;
}

- (void)refreshUser:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] getCurrentUser:^(User *user, NSError *error) {
        if (!error) {
            _user = user;
            [self sendNotification];
        } else
            NSLog(@"Error getting user: %@", [error localizedDescription]);
        completionHandler(self.user, error);
    }];
}

- (void)updateUser:(User *)user completion:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] updateUser:user completion:^(User *user, NSError *error) {
        if (!error) {
            _user = user;
            [self sendNotification];
        }
        completionHandler(user, error);
    }];
}

- (void)login:(LoginRequest *)request completion:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] authenticateUser:request completion:^(LoginResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        [self saveRequest:request andResponse:response];
        [self refreshUser:completionHandler];
        [self submitDeviceToken];
    }];
}

- (void)signup:(SignupRequest *)request completion:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] sendSignUpWithRequest:request completion:^(LoginResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        [self saveRequest:(LoginRequest *)request andResponse:response];
        [self refreshUser:completionHandler];
        [self submitDeviceToken];
    }];
}

- (void)signout:(void (^)(NSError *))completionHandler {
    [[WebApi sharedInstance] signoutCompletion:^(NSError *error) {
        _user = nil;
        [self clearSavedCredentials];
        completionHandler(error);
    }];
    

}

- (void)clearSavedCredentials {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"User"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LoginResponseKey];
    [self.keychain resetKeychainItem];
    [self removeToken];
}

- (void)removeToken {
    NSString *deviceTokenId = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceTokenIdKey];
    
    if (!deviceTokenId)
        return;
    
    
    [[WebApi sharedInstance] deleteToken:deviceTokenId completion:^(NSError *error) {}];
}


- (void)submitDeviceToken {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceTokenKey];
    
    if (!deviceToken)
        return;
    
    DeviceToken *token = [[DeviceToken alloc] init];
    token.token = deviceToken;
    
    [[WebApi sharedInstance] sendToken:token completion:^(NSString *tokenId, NSError *error) {
        if (!error)
            [[NSUserDefaults standardUserDefaults] setObject:tokenId forKey:kDeviceTokenIdKey];
    }];
}

- (LoginRequest *)loginRequestForSavedUser {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey: @"User"];
    NSString *password = [self.keychain objectForKey: ((__bridge id)kSecValueData)];
    
    if (!username || !password)
        return nil;
    
    LoginRequest *request = [[LoginRequest alloc] init];
    request.login = username;
    request.password = password;
    
    return request;
}


- (void)saveRequest:(LoginRequest *)request andResponse:(LoginResponse *)response {
    
    [[NSUserDefaults standardUserDefaults] setObject:request.login forKey: @"User"];
    [[NSUserDefaults standardUserDefaults] setObject:response.token forKey:LoginResponseKey];
    [self.keychain setObject:request.password forKey:((__bridge id)kSecValueData)];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)uploadProfileImage:(UIImage *)profileImage completion:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] uploadProfileImage:profileImage completion:^(NSError *error) {
        [self refreshUser:completionHandler];
    }];
}

- (void)sendNotification {
    [[NSUserDefaults standardUserDefaults] setObject:self.user.name forKey: @"User"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserChangedNotificationName object:self userInfo:@{ChangedUserKey: self.user}];
}

@end
