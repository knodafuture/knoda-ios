//
//  SignupRequest.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SignupRequest.h"

@implementation SignupRequest

- (NSDictionary *)parametersDictionary {
    return @{@"user[username]" : self.username, @"user[email]" : self.email, @"user[password]" : self.password};
}

@end
