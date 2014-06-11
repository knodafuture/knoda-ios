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
            [[WebApi sharedInstance] getGroups:^(NSArray *groups, NSError *error) {
                if (!error)
                    _groups = groups;
                completionHandler(user, error);
            }];
        } else {
            NSLog(@"Error getting user: %@", [error localizedDescription]);
            completionHandler(nil, error);
        }
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

- (void)socialSignIn:(SocialAccount *)request completion:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] socialSignIn:request completion:^(LoginResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        [self saveSocialSignInRequest:request andResponse:response];
        [self refreshUser:completionHandler];
        [self submitDeviceToken];
    }];
}

- (void)addSocialAccount:(SocialAccount *)account completion:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] addSocialAccount:account completion:^(SocialAccount *account, NSError *error) {
        if (error) {
            completionHandler(_user, error);
            return;
        }
        [self refreshUser:completionHandler];
    }];
}

- (void)deleteSocialAccount:(SocialAccount *)account completion:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] deleteSocialAccount:account completion:^(NSError *error) {
        if (error) {
            completionHandler(_user, error);
            return;
        }
        [self refreshUser:completionHandler];
    }];
}

- (void)signup:(SignupRequest *)request completion:(void (^)(User *, NSError *))completionHandler {
    [[WebApi sharedInstance] sendSignUpWithRequest:request completion:^(LoginResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        [self saveSignUpRequest:request andResponse:response];
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SavedSocialAccount"];
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

- (void)authenticateSavedUser:(void (^)(User *, NSError *))completionHandler {
    LoginRequest *request = [self loginRequestForSavedUser];
    
    if (request) {
        [self login:request completion:completionHandler];
        NSString *inStr = [@(self.user.userId) stringValue];
        [Flurry setUserID:inStr];
        return;
    }
    
    SocialAccount *savedAccount = [self socialAccountForSavedUser];
    
    if (savedAccount) {
        [self socialSignIn:savedAccount completion:completionHandler];
        NSString *inStr = [@(self.user.userId) stringValue];
        [Flurry setUserID:inStr];
        return;
    }
    
    completionHandler(nil, [NSError errorWithDomain:@"usermanager" code:404 userInfo:nil]);
}

- (LoginRequest *)loginRequestForSavedUser {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey: @"User"];
    NSString *password = [self.keychain objectForKey: ((__bridge id)kSecValueData)];
    
    if (password.length == 0)
        return nil;
    
    LoginRequest *request = [[LoginRequest alloc] init];
    request.login = username;
    request.password = password;
    
    return request;
}

- (SocialAccount *)socialAccountForSavedUser {
    NSDictionary *savedAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedSocialAccount"];
    if (!savedAccount)
        return nil;
    
    return [MTLJSONAdapter modelOfClass:SocialAccount.class fromJSONDictionary:savedAccount error:nil];
}

- (void)saveSignUpRequest:(SignupRequest *)request andResponse:(LoginResponse *)response {
    [[NSUserDefaults standardUserDefaults] setObject:request.email forKey: @"User"];
    [[NSUserDefaults standardUserDefaults] setObject:response.token forKey:LoginResponseKey];
    [self.keychain setObject:request.password forKey:((__bridge id)kSecValueData)];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self clearSocialLoginData];
}

- (void)saveRequest:(LoginRequest *)request andResponse:(LoginResponse *)response {
    
    [[NSUserDefaults standardUserDefaults] setObject:request.login forKey: @"User"];
    [[NSUserDefaults standardUserDefaults] setObject:response.token forKey:LoginResponseKey];
    [self.keychain setObject:request.password forKey:((__bridge id)kSecValueData)];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self clearSocialLoginData];
}

- (void)saveSocialSignInRequest:(SocialAccount *)request andResponse:(LoginResponse *)response {
    [[NSUserDefaults standardUserDefaults] setObject:[MTLJSONAdapter JSONDictionaryFromModel:request] forKey:@"SavedSocialAccount"];
    [[NSUserDefaults standardUserDefaults] setObject:response.token forKey:LoginResponseKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self clearLoginData];
}

- (void)clearLoginData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"User"];
    [self.keychain resetKeychainItem];
}

- (void)clearSocialLoginData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SavedSocialAccount"];
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
