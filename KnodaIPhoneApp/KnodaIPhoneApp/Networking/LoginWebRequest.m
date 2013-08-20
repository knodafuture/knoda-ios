//
//  LoginWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "LoginWebRequest.h"
#import "User.h"

@implementation LoginWebRequest


- (id) initWithUsername: (NSString*) userName password: (NSString*) password
{
    NSDictionary* theParameters = @{@"user[login]" : userName, @"user[password]" : password};
    
    self = [super initWithParameters: theParameters];
    return self;
}


- (NSString*) methodName
{
    return @"session.json";
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Login Result: %@", parsedResult);
    
    self.user = [[User alloc] initWithDictionary:parsedResult];
    self.user.token = [parsedResult objectForKey: @"auth_token"];
}

@end
