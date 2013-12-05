//
//  LoginRequest.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoginRequest.h"

@implementation LoginRequest

- (NSDictionary *)parametersDictionary {
    return @{@"user[login": self.username, @"user[password]" : self.password};

}

@end
