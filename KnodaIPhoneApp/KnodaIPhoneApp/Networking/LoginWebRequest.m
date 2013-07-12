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
    NSDictionary* theParameters = @{@"user_login[login]" : @"test", @"user_login[password]" : @"password"};
    
    self = [super initWithParameters: theParameters];
    return self;
}


- (NSString*) methodName
{
    return @"sessions.json";
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Login Result: %@", parsedResult);
    
    self.user = [[User alloc] init];
    self.user.name = [parsedResult objectForKey: @"username"];
    self.user.email = [parsedResult objectForKey: @"email"];
    self.user.token = [parsedResult objectForKey: @"auth_token"];
}

@end
