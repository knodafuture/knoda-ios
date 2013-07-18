//
//  SugnUpRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SignUpRequest.h"
#import "User.h"

@interface SignUpRequest ()

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* email;

@end


@implementation SignUpRequest

- (id) initWithUsername: (NSString*) userName email: (NSString*) email password: (NSString*) password
{
    NSDictionary* theParameters = @{@"user[username]" : userName, @"user[email]" : email, @"user[password]" : password};
    
    self = [super initWithParameters: theParameters];
    
    if (self != nil)
    {
        self.username = userName;
        self.email = email;
    }
    
    return self;
}


- (NSString*) methodName
{
    return @"registration.json";
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
    self.user.token = [parsedResult objectForKey: @"auth_token"];
}

@end
