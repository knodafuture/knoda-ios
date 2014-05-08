//
//  TwitterManager.h
//  KnodaIPhoneApp
//
//  Created by nick on 5/1/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialAccount.h"
#import <Accounts/Accounts.h>

@interface TwitterManager : NSObject

+ (TwitterManager *)sharedInstance;

- (void)performReverseAuth:(void(^)(SocialAccount *request, NSError *error))completionHandler;
@end
