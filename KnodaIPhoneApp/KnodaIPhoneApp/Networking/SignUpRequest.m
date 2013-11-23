//
//  SugnUpRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "SignUpRequest.h"
#import "User.h"
#import "BadgesWebRequest.h"

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
    
    self.user = [[User alloc] initWithDictionary:parsedResult];
    self.user.token = [parsedResult objectForKey: @"auth_token"];
}

- (void)executeWithCompletionBlock:(RequestCompletionBlock)completion {
    RequestCompletionBlock block = completion ? [completion copy] : nil;
    [super executeWithCompletionBlock:^{
        if(block) {
            block();
        }
    }];
}

@end
