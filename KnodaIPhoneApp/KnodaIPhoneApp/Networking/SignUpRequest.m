//
//  SugnUpRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SignUpRequest.h"
#import "User.h"

@implementation SignUpRequest

- (id) initWithUsername: (NSString*) userName email: (NSString*) email password: (NSString*) password
{
    NSDictionary* theParameters = @{@"user[username]" : @"newuser1", @"user[email]" : @"email1@mail.com", @"user[password]" : @"password"};
    
    self = [super initWithParameters: theParameters];
    return self;
}


- (NSString*) methodName
{
    return @"registrations.json";
}


- (NSString*) httpMethod
{
    return @"POST";
}


- (void) fillResultObject: (id) parsedResult
{
    NSLog(@"Sign Up Result: %@", parsedResult);
    
    self.user = [[User alloc] init];
    self.user.name = [parsedResult objectForKey: @"username"];
    self.user.email = [parsedResult objectForKey: @"email"];
}

@end
