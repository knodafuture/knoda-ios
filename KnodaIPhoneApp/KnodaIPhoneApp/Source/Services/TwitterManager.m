//
//  TwitterManager.m
//  KnodaIPhoneApp
//
//  Created by nick on 5/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "TwitterManager.h"
#import <Accounts/Accounts.h>
#import "TWAPIManager.h"
#import "AppDelegate.h"
#import "UIActionSheet+Blocks.h"
#import "LoadingView.h"

#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in your iPhone's settings to continue."
#define ERROR_PERM_ACCESS @"Sorry, you can't sign in with Twitter without granting us access to the accounts on your device."
#define ERROR_OK @"OK"

static TwitterManager *sharedSingleton;

@interface TwitterManager ()
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *twitterAccounts;

@end

@implementation TwitterManager

+ (TwitterManager *)sharedInstance {
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
    });
    
    return sharedSingleton;
}


- (id)init {
    self = [super init];
    self.accountStore = [[ACAccountStore alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
    return self;
}

- (void)performReverseAuthForAccount:(ACAccount *)account completion:(void(^)(SocialAccount *, NSError *))completionHandler {
    
    [[LoadingView sharedInstance] show];
    [[TWAPIManager sharedInstance] performReverseAuthForAccount:account withHandler:^(ReverseAuthResponse *response, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SocialAccount *request = [[SocialAccount alloc] init];
                request.providerName = @"twitter";
                request.providerId = response.providerId;
                request.accessToken = response.token;
                request.accessTokenSecret = response.tokenSecret;
                completionHandler(request, nil);
                
            });
        }
        else {
            completionHandler(nil, error);
        }
    }];
}

- (void)getTwitterAccounts:(void (^)(NSArray *, NSError *))completionHandler {
    [self _refreshTwitterAccounts:^(BOOL granted) {
        if (!granted) {
            completionHandler(nil, [NSError errorWithDomain:@"twitter" code:401 userInfo:nil]);
            return;
        }
        completionHandler(self.twitterAccounts, nil);
    }];
}

- (void)_refreshTwitterAccounts:(void(^)(BOOL))completion {
    if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_ACCOUNTS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
        completion(NO);
    }
    else {
        [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_PERM_ACCESS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
                    [alert show];
                }
                completion(granted);
            });
        }];
    }
}

- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block {
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.twitterAccounts = [self.accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    [self.accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}


- (void)performReverseAuth:(void (^)(SocialAccount *, NSError *))completionHandler {
    [self getTwitterAccounts:^(NSArray *accounts, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        if (accounts.count == 1) {
            [self performReverseAuthForAccount:[accounts firstObject] completion:^(SocialAccount *request, NSError *error) {
                completionHandler(request, error);
            }];
        } else {
            [self showAccountSelector:completionHandler];
        }
    }];
}

- (void)showAccountSelector:(void(^)(SocialAccount *account, NSError *error))completionHandler {
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (ACAccount *acct in self.twitterAccounts) {
        [sheet addButtonWithTitle:acct.username];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    
    __unsafe_unretained TwitterManager *this = self;
    sheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [self performReverseAuthForAccount:[this.twitterAccounts objectAtIndex:buttonIndex] completion:completionHandler];
        }
    };
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [sheet showInView:delegate.window.rootViewController.view];
}
@end
