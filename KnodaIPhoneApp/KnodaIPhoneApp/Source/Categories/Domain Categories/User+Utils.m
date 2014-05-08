//
//  NewUser+Utils.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "User+Utils.h"

@implementation User (Utils)

- (BOOL)hasAvatar {
    return self.avatar != nil;
}

- (SocialAccount *)twitterAccount {
    for (SocialAccount *account in self.socialAccounts) {
        if ([account.providerName isEqualToString:@"twitter"])
            return account;
    }
    
    return nil;
}

- (SocialAccount *)facebookAccount {
    for (SocialAccount *account in self.socialAccounts) {
        if ([account.providerName isEqualToString:@"facebook"])
            return account;
    }
    
    return nil;
}

@end
