//
//  SignOutWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/20/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SignOutWebRequest.h"

@implementation SignOutWebRequest

- (NSString*) methodName
{
    return @"session.json";
}


- (NSString*) httpMethod
{
    return @"DELETE";
}

@end
